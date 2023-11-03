resource "helm_release" "ebs_csi_controller" {
  chart      = var.helm_chart_name
  namespace  = var.namespace
  name       = var.helm_release_name
  version    = var.helm_chart_version
  repository = var.helm_repo_url

  dynamic "set" {
    for_each = {
      "controller.k8sTagClusterId"                                           = var.cluster_id
      "image.repository"                                                     = "public.ecr.aws/ebs-csi-driver/aws-ebs-csi-driver"
      "image.tag"                                                            = var.image_version
      "controller.serviceAccount.create"                                     = "true"
      "controller.serviceAccount.name"                                       = var.service_account_name
      "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = aws_iam_role.this.arn
    }

    content {
      name  = set.key
      value = set.value
    }
  }
}
