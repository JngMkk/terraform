resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    security_group_ids = [aws_security_group.cluster_sg.id]
    subnet_ids         = var.private_sn_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policies,
    aws_iam_policy_attachment.eks_management_policy_attachment
  ]
}

data "aws_eks_addon_version" "this" {
  for_each = { for k, v in var.cluster_addons : k => v }

  addon_name         = try(each.value.name, each.key)
  kubernetes_version = aws_eks_cluster.eks_cluster.version
  most_recent        = try(each.value.most_recent, null)
}

resource "aws_eks_addon" "this" {
  for_each = { for k, v in var.cluster_addons : k => v }

  cluster_name = aws_eks_cluster.eks_cluster.name
  addon_name   = try(each.value.name, each.key)

  addon_version               = coalesce(try(each.value.addon_version, null), data.aws_eks_addon_version.this[each.key].version)
  configuration_values        = try(each.value.configuration_values, null)
  preserve                    = try(each.value.preserve, null)
  resolve_conflicts_on_update = try(each.value.resolve_conflicts, "OVERWRITE")
  service_account_role_arn    = try(each.value.service_account_role_arn, null)

  depends_on = [aws_eks_node_group.eks_node_groups]
}
