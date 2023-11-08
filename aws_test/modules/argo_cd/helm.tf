data "aws_acm_certificate" "this" {
  domain = var.domain
}

resource "helm_release" "this" {
  count      = var.enabled ? 1 : 0
  chart      = var.helm_chart_name
  namespace  = var.namespace
  name       = var.helm_release_name
  version    = var.helm_chart_version
  repository = var.helm_repo_url

  timeout                    = var.helm_timeout
  disable_webhooks           = var.helm_disable_webhooks
  reset_values               = var.helm_reset_values
  reuse_values               = var.helm_reuse_values
  force_update               = var.helm_force_update
  recreate_pods              = var.helm_recreate_pods
  cleanup_on_fail            = var.helm_cleanup_on_fail
  max_history                = var.helm_release_max_history
  atomic                     = var.helm_atomic
  wait                       = var.helm_wait
  wait_for_jobs              = var.helm_wait_for_jobs
  skip_crds                  = var.helm_skip_crds
  render_subchart_notes      = var.helm_render_subchart_notes
  disable_openapi_validation = var.helm_disable_openapi_validation
  dependency_update          = var.helm_dependency_update
  replace                    = var.helm_replace
  description                = var.helm_description
  lint                       = var.helm_lint

  values = [
    templatefile(
      "./modules/argo_cd/values.yaml.tpl",
      {
        "aws_acm_arn"        = "${data.aws_acm_certificate.this.arn}"
        "argocd_server_host" = "${var.argocd_host}"
      }
    )
  ]
}
