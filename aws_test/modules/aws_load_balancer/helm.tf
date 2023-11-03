resource "helm_release" "lb_controller" {
  name       = var.helm_chart_name
  chart      = var.helm_chart_release_name
  repository = var.helm_chart_repo
  version    = var.helm_chart_version
  namespace  = var.namespace

  dynamic "set" {
    for_each = {
      "clusterName"                                               = var.cluster_name
      "rbac.create"                                               = "true"
      "serviceAccount.create"                                     = "true"
      "serviceAccount.name"                                       = var.service_account_name
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = aws_iam_role.lb_controller.arn
    }

    content {
      name  = set.key
      value = set.value
    }
  }
}
