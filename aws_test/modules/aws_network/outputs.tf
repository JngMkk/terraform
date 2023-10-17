output "vpc_id" {
  value = aws_vpc.vpc[0].id
}

output "public_sn_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_sn_ids" {
  value = aws_subnet.private_subnets[*].id
}
