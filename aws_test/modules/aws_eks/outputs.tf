output "eks_cluster_id" {
  value = aws_eks_cluster.eks_cluster.id
}

output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "eks_cluster_certificate_data" {
  value     = aws_eks_cluster.eks_cluster.certificate_authority.0.data
  sensitive = true
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_node_group_id" {
  value = aws_eks_node_group.eks_node_group.id
}
