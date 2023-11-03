locals {
  role_name = "${var.cluster_name}-${var.role_name}"
}

data "aws_caller_identity" "current" {}

data "http" "csi_driver_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/helm-chart-aws-ebs-csi-driver-2.10.1/docs/example-iam-policy.json"
}

data "aws_iam_policy_document" "irsa" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_identity_oidc_issuer, "https://", "")}:sub"
      values = [
        "system:serviceaccount:${var.namespace}:${var.service_account_name}"
      ]
    }

    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.cluster_identity_oidc_issuer, "https://", "")}"
      ]
      type = "Federated"
    }
  }
}

resource "aws_iam_policy" "this" {
  name        = local.role_name
  path        = "/"
  description = "Policy for EBS CSI driver"
  policy      = data.http.csi_driver_policy.response_body
}

resource "aws_iam_role" "this" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.irsa.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
