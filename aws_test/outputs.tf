output "vpc_id" {
  value = module.aws_network.vpc_id
}

output "public_sn_ids" {
  value = module.aws_network.public_sn_ids
}

output "private_sn_ids" {
  value = module.aws_network.private_sn_ids
}
