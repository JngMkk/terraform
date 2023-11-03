variable "cluster_name" {
  type = string
}

variable "cluster_identity_oidc_issuer" {
  type = string
}

variable "helm_chart_name" {
  type    = string
  default = "aws-load-balancer-controller"
}

variable "helm_chart_release_name" {
  type    = string
  default = "aws-load-balancer-controller"
}

variable "helm_chart_repo" {
  type    = string
  default = "https://aws.github.io/eks-charts"
}

variable "helm_chart_version" {
  type    = string
  default = "1.6.1"
}

variable "namespace" {
  type = string
}

variable "service_account_name" {
  type    = string
  default = "aws-load-balancer-controller"
}

variable "permissions_boundary" {
  type        = string
  default     = null
  description = "If provided, all IAM roles will be created with this permissions boundary attached."
}

variable "role_name" {
  type    = string
  default = "alb-ingress"
}

variable "vpc_id" {
  type = string
}
