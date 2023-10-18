locals {
  cluster_name = var.cluster_name
}

resource "aws_iam_role" "cluster_role" {
  name               = "${local.cluster_name}-role"
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
  name               = "${local.cluster_name}-node-role"
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
  name   = "${local.cluster_name}-sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = var.sg_egress.from_port
    to_port     = var.sg_egress.to_port
    protocol    = var.sg_egress.protocol
    cidr_blocks = var.sg_egress.cidr_blocks
  }
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = local.cluster_name
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    security_group_ids = [aws_security_group.cluster_sg.id]
    subnet_ids         = var.cluster_subnet_ids
  }

  depends_on = [aws_iam_role_policy_attachment.cluster_policies]
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.node_group_subnet_ids

  disk_size      = var.node_group_disk_size
  instance_types = var.node_group_instance_types

  scaling_config {
    desired_size = var.node_group_scaling_config.desired_size
    min_size     = var.node_group_scaling_config.min_size
    max_size     = var.node_group_scaling_config.max_size
  }

  depends_on = [aws_iam_role_policy_attachment.node_role_policies]
}

resource "local_file" "kubeconfig" {
  content  = <<KUBECONFIG_END
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${aws_eks_cluster.eks_cluster.certificate_authority.0.data}
    server: ${aws_eks_cluster.eks_cluster.endpoint}
  name: ${aws_eks_cluster.eks_cluster.arn}
contexts:
- context:
    cluster: ${aws_eks_cluster.eks_cluster.arn}
    user: ${aws_eks_cluster.eks_cluster.arn}
  name: ${aws_eks_cluster.eks_cluster.arn}
current-context: ${aws_eks_cluster.eks_cluster.arn}
kind: Config
preferences: {}
users:
- name: ${aws_eks_cluster.eks_cluster.arn}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${aws_eks_cluster.eks_cluster.name}"
  KUBECONFIG_END
  filename = var.kubeconfig_filename
}
