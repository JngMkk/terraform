data "aws_ssm_parameter" "image" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.eks_cluster.version}/amazon-linux-2/recommended/image_id"

  depends_on = [aws_iam_policy_attachment.eks_management_policy_attachment]
}

resource "aws_launch_template" "templates" {
  count = length(var.ngs)

  name          = var.ngs[count.index].template_name
  image_id      = data.aws_ssm_parameter.image.value
  instance_type = var.ngs[count.index].instance_type
  key_name      = var.key_name
  user_data = base64encode(
    templatefile(
      var.template_file_path,
      {
        CLUSTER_NAME   = aws_eks_cluster.eks_cluster.name,
        B64_CLUSTER_CA = aws_eks_cluster.eks_cluster.certificate_authority.0.data,
        API_SERVER_URL = aws_eks_cluster.eks_cluster.endpoint
      }
    )
  )

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  monitoring {
    enabled = false
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name                        = "${var.ngs[count.index].ng_name}"
      "kubernetes.io/cluster/eks" = "owned"
    }
  }
}

resource "aws_eks_node_group" "eks_node_groups" {
  count = length(var.ngs)

  cluster_name  = aws_eks_cluster.eks_cluster.name
  node_role_arn = aws_iam_role.node_role.arn
  subnet_ids    = var.private_sn_ids

  node_group_name = var.ngs[count.index].ng_name
  labels          = { "role" : "${var.ngs[count.index].role}" }

  launch_template {
    id      = aws_launch_template.templates[count.index].id
    version = aws_launch_template.templates[count.index].latest_version
  }

  scaling_config {
    desired_size = var.ngs[count.index].desired_size
    min_size     = var.ngs[count.index].min_size
    max_size     = var.ngs[count.index].max_size
  }

  tags = {
    "kubernetes.io/cluster/eks" = "owned"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_role_policies,
    aws_iam_policy_attachment.eks_management_policy_attachment,
    aws_launch_template.templates
  ]
}