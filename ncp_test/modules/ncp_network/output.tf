output "public_subnet_id" {
  value = ncloud_subnet.public_subnet.id
}

output "private_subnet_ids" {
  value = ncloud_subnet.private_subnets[*].id
}

output "vpc_id" {
  value = ncloud_vpc.vpc.id
}
