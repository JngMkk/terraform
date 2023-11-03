resource "aws_iam_policy" "eks_management_policy" {
  name = var.eks_management_policy_name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:ListUsers",
          "iam:CreateGroup",
          "iam:DeleteGroup",
          "iam:ListGroups",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:ListRoles",
        ],
        Resource = "*",
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:Describe*",
          "ecr:GetAuthorizationToken",
          "eks:DescribeNodegroup",
          "eks:DeleteNodegroup",
          "eks:ListClusters",
          "eks:CreateCluster",
          "eks:*",
          "route53:*",
          "s3:*",
        ],
        Resource = "*",
      },
      {
        Effect   = "Allow",
        Action   = "eks:*",
        Resource = "arn:aws:eks:*:*:cluster/*",
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:Describe*",
          "ssm:Get*",
          "ssm:List*"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "acm:DescribeCertificate",
          "acm:ListCertificates",
          "acm:GetCertificate",
          "acm:ListTagsForCertificate",
          "acm:GetAccountConfiguration"
        ],
        "Resource" : "*"
      }
    ],
  })
}

resource "aws_iam_policy_attachment" "eks_management_policy_attachment" {
  name       = var.eks_management_policy_name
  policy_arn = aws_iam_policy.eks_management_policy.arn
  groups     = [var.ops_group_name]

  depends_on = [aws_iam_policy.eks_management_policy]
}

resource "aws_iam_role" "cluster_role" {
  name               = "${var.cluster_name}-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cluster_policies" {
  count = length(var.cluster_role_policy_arns)

  policy_arn = var.cluster_role_policy_arns[count.index]
  role       = aws_iam_role.cluster_role.name
}

resource "aws_iam_role" "node_role" {
  name               = "${var.cluster_name}-node-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "node_role_policies" {
  count = length(var.node_role_policy_arns)

  policy_arn = var.node_role_policy_arns[count.index]
  role       = aws_iam_role.node_role.name
}

resource "aws_security_group" "cluster_sg" {
  name   = "${var.cluster_name}-sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = var.sg_egress.from_port
    to_port     = var.sg_egress.to_port
    protocol    = var.sg_egress.protocol
    cidr_blocks = var.sg_egress.cidr_blocks
  }
}

data "tls_certificate" "tls_cert" {
  url = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.tls_cert.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}

data "aws_iam_policy_document" "aws_node_policy_document" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace("${aws_iam_openid_connect_provider.oidc_provider.url}", "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.aws_node}"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc_provider.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "node_oidc_role" {
  assume_role_policy = data.aws_iam_policy_document.aws_node_policy_document.json
  name               = var.aws_node
}

resource "aws_eks_identity_provider_config" "oidc_config" {
  cluster_name = var.cluster_name

  oidc {
    client_id                     = substr(aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer, -32, -1)
    identity_provider_config_name = var.oidc_config_name
    issuer_url                    = "https://${aws_iam_openid_connect_provider.oidc_provider.url}"
  }
}
