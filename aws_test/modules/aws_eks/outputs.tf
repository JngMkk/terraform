output "eks_cluster_id" {
  value = aws_eks_cluster.eks_cluster.id
}

output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "eks_cluster_node_group_ids" {
  value = aws_eks_node_group.eks_node_groups[*].id
}

output "eks_cluster_identity_oidc_issuer" {
  value = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}

output "eks_cluster_role_arn" {
  value = aws_iam_role.cluster_role.arn
}
