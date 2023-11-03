locals {
  role_name = "${var.cluster_name}-${var.role_name}"
}

data "aws_caller_identity" "current" {}

data "http" "lb_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json"
}

data "aws_iam_policy_document" "lb_controller_assume" {
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

resource "aws_iam_role" "lb_controller" {
  name                 = local.role_name
  assume_role_policy   = data.aws_iam_policy_document.lb_controller_assume.json
  permissions_boundary = var.permissions_boundary
}

resource "aws_iam_role_policy" "lb_controller" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  role   = aws_iam_role.lb_controller.id
  policy = data.http.lb_policy.response_body
}
