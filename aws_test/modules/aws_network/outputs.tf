output "vpc_id" {
  value = local.create_vpc ? aws_vpc.vpc[0].id : ""
}

output "public_sn_ids" {
  value = local.create_public_subnets ? aws_subnet.public_subnets[*].id : [""]
}

output "private_sn_ids" {
  value = local.create_private_subnets ? aws_subnet.private_subnets[*].id : [""]
}
