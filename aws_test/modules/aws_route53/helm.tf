data "aws_region" "current" {}

resource "helm_release" "external_dns" {
  chart      = var.helm_chart_name
  namespace  = var.namespace
  name       = var.helm_release_name
  version    = var.helm_chart_version
  repository = var.helm_repo_url

  dynamic "set" {
    for_each = {
      "aws.region"                                                = data.aws_region.current.name
      "rbac.create"                                               = "true"
      "serviceAccount.create"                                     = "true"
      "serviceAccount.name"                                       = var.service_account_name
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = aws_iam_role.external_dns.arn
    }

    content {
      name  = set.key
      value = set.value
    }
  }
}
