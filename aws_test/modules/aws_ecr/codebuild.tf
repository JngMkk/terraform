locals {
  len_codebuilds = length(var.codebuild_resources)
  vpc_id         = var.vpc_id
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_security_group" "sg_web" {
  name   = var.sg_web
  vpc_id = local.vpc_id

  egress {
    from_port   = var.sg_egress["from_port"]
    to_port     = var.sg_egress["to_port"]
    protocol    = var.sg_egress["protocol"]
    cidr_blocks = var.sg_egress["cidr_blocks"]
  }
}

resource "aws_security_group_rule" "sg_web_ingress" {
  count = length(var.sg_web_ingress)

  security_group_id = aws_security_group.sg_web.id
  type              = "ingress"

  from_port   = var.sg_web_ingress[count.index]["from_port"]
  to_port     = var.sg_web_ingress[count.index]["to_port"]
  protocol    = var.sg_web_ingress[count.index]["protocol"]
  cidr_blocks = var.sg_web_ingress[count.index]["cidr_blocks"]
}

resource "aws_iam_role" "codebuild_role" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  max_session_duration = "3600"
  name                 = "CodeBuildRole"
  path                 = "/"
}

resource "aws_iam_role_policy" "codebuild_access_policy" {
  name   = "CodeBuildAccess"
  role   = aws_iam_role.codebuild_role.name
  policy = <<POLICY
{
  "Statement": [
    {
      "Action": [
        "logs:*",
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeVpcs",
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

resource "aws_iam_role_policy_attachment" "codebuild_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = aws_iam_role.codebuild_role.name
}

# resource "aws_iam_policy" "codebuild_policies" {
#   count = local.len_codebuilds

#   name = "${var.codebuild_resources[count.index].name}-policy"
#   path = "/service-role/"

#   policy = <<POLICY
# {
#   "Statement": [
#     {
#       "Action": [
#         "logs:CreateLogGroup",
#         "logs:CreateLogStream",
#         "logs:PutLogEvents"
#       ],
#       "Effect": "Allow",
#       "Resource": [
#         "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:log-group:/aws/codebuild/${var.codebuild_resources[count.index].name}",
#         "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:log-group:/aws/codebuild/${var.codebuild_resources[count.index].name}:*"
#       ]
#     },
#     {
#       "Action": [
#         "codebuild:CreateReportGroup",
#         "codebuild:CreateReport",
#         "codebuild:UpdateReport",
#         "codebuild:BatchPutTestCases",
#         "codebuild:BatchPutCodeCoverages"
#       ],
#       "Effect": "Allow",
#       "Resource": [
#         "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:report-group/${var.codebuild_resources[count.index].name}-*"
#       ]
#     }
#   ],
#   "Version": "2012-10-17"
# }
# POLICY
# }

# resource "aws_iam_role_policy_attachment" "policies_attachment" {
#   count = local.len_codebuilds

#   policy_arn = aws_iam_policy.codebuild_policies[count.index].arn
#   role       = aws_iam_role.codebuild_role.name
# }

resource "aws_codebuild_source_credential" "this" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = "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"
}

resource "aws_codebuild_project" "aws_codebuilds" {
  count = local.len_codebuilds

  source {
    type                = var.source_type
    location            = "${var.github_prefix}${var.codebuild_resources[count.index].github_repo}${var.github_suffix}"
    buildspec           = var.buildspec
    git_clone_depth     = var.git_clone_depth
    insecure_ssl        = var.insecure_ssl
    report_build_status = var.report_build_status

    git_submodules_config {
      fetch_submodules = var.fetch_submodules
    }
  }

  environment {
    type                        = var.env_type
    compute_type                = var.env_compute_type
    image                       = var.env_image
    image_pull_credentials_type = var.image_pull_credentials_type
    privileged_mode             = var.privileged_mode

    environment_variable {
      name  = "REGISTRY_HOST"
      type  = var.env_variable_type
      value = "${data.aws_caller_identity.current.id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
    }

    environment_variable {
      name  = "IMAGE_NAME"
      type  = var.env_variable_type
      value = var.codebuild_resources[count.index].image_name
    }

    environment_variable {
      name  = "IMAGE_TAG"
      type  = var.env_variable_type
      value = reverse(split("-", var.codebuild_resources[count.index].name))[0] == "dev" ? "dev" : "prod"
    }

    environment_variable {
      name  = "DOCKERFILE"
      type  = var.env_variable_type
      value = var.codebuild_resources[count.index].dockerfile
    }

    environment_variable {
      name  = "REGION"
      type  = var.env_variable_type
      value = data.aws_region.current.name
    }
  }

  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = var.subnet_ids
    security_group_ids = [aws_security_group.sg_web.id]
  }

  artifacts {
    type = var.artifact_type
  }

  cache {
    type = var.cache
  }

  name                   = var.codebuild_resources[count.index].name
  source_version         = var.codebuild_resources[count.index].source_version
  badge_enabled          = var.badge_enabled
  build_timeout          = var.timeout
  concurrent_build_limit = var.concurrent_build_limit
  service_role           = aws_iam_role.codebuild_role.arn
}
