variable "cluster_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "role_name" {
  type    = string
  default = "ebs-csi-driver"
}

variable "cluster_identity_oidc_issuer" {
  type = string
}

variable "namespace" {
  type = string
}

variable "service_account_name" {
  type    = string
  default = "ebs-csi-controller-sa"
}

variable "helm_chart_name" {
  type    = string
  default = "aws-ebs-csi-driver"
}

variable "helm_release_name" {
  type    = string
  default = "aws-ebs-csi-driver"
}

variable "helm_repo_url" {
  type    = string
  default = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
}

variable "helm_chart_version" {
  type    = string
  default = "2.24.1"
}

# https://gallery.ecr.aws/ebs-csi-driver/aws-ebs-csi-driver
variable "image_version" {
  type    = string
  default = "v1.24.1"
}
