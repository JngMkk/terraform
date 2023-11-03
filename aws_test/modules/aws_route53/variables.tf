variable "cluster_name" {
  type = string
}

variable "policy_allowed_zone_ids" {
  type    = list(string)
  default = ["*"]
}

variable "cluster_identity_oidc_issuer" {
  type = string
}

variable "helm_chart_name" {
  type    = string
  default = "external-dns"
}

variable "helm_chart_version" {
  type    = string
  default = "6.27.0"
}

variable "helm_release_name" {
  type    = string
  default = "external-dns"
}

variable "helm_repo_url" {
  type    = string
  default = "https://charts.bitnami.com/bitnami"
}

variable "namespace" {
  type = string
}

variable "service_account_name" {
  type    = string
  default = "external-dns"
}
