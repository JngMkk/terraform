terraform {
  required_version = "~> 1.9.0"

  required_providers {
    ncloud = {
      source  = "NaverCloudPlatform/ncloud"
      version = "3.1.1"
    }
  }
}

locals {
  len_private_subnets    = length(var.private_subnet_cidr_blocks)
  create_private_subnets = local.len_private_subnets > 0
}


###############################################################################
#                                     VPC                                     #
###############################################################################
resource "ncloud_vpc" "vpc" {
  name            = var.vpc_name
  ipv4_cidr_block = var.vpc_ipv4_cidr_block
}


# ###############################################################################
# #                                     ACL                                     #
# ###############################################################################
resource "ncloud_network_acl" "acl" {
  name = var.acl_name

  vpc_no = ncloud_vpc.vpc.id
}

# # resource "ncloud_network_acl_rul" "public_nacl_rule" {
# #   network_acl_no = ncloud_network_acl.nacl.id

# #   inbound {
# #     priority    = 100
# #     protocol    = "TCP"
# #     rule_action = "ALLOW"
# #     ip_block    = "0.0.0.0/0"
# #     port_range  = "22"
# #   }

# #   inbound {
# #     priority    = 110
# #     protocol    = "TCP"
# #     rule_action = "ALLOW"
# #     ip_block    = "0.0.0.0/0"
# #     port_range  = "443"
# #   }

# #   inbound {
# #     priority = 120
# #     protocol = "TCP"
# #     rule_action = "ALLOW"
# #     ip_block = "0.0.0.0/0"
# #     port_range = "80"
# #   }

# #   outbound {
# #     priority    = 100
# #     protocol    = "TCP"
# #     rule_action = "ALLOW"
# #     ip_block    = "0.0.0.0/0"
# #     port_range  = "1-65535"
# #   }
# # }


###############################################################################
#                                  ALB SUBNET                                 #
###############################################################################
resource "ncloud_subnet" "public_subnet_alb" {
  subnet      = var.public_subnet_alb_cidr_block
  zone        = var.subnet_zone
  subnet_type = var.public_subnet_alb_subnet_type
  name        = var.public_subnet_alb_name
  usage_type  = var.public_subnet_alb_usage_type

  vpc_no         = ncloud_vpc.vpc.id
  network_acl_no = ncloud_network_acl.acl.id
}


###############################################################################
#                                     ALB                                     #
###############################################################################
resource "ncloud_lb" "alb" {
  name         = var.alb_name
  network_type = var.alb_network_type
  type         = var.alb_type

  subnet_no_list = [ncloud_subnet.public_subnet_alb.subnet_no]
}


###############################################################################
#                                  NGW SUBNET                                 #
###############################################################################
resource "ncloud_subnet" "public_subnet_ngw" {
  subnet      = var.public_subnet_ngw_cidr_block
  zone        = var.subnet_zone
  subnet_type = var.public_subnet_ngw_subnet_type
  name        = var.public_subnet_ngw_name
  usage_type  = var.public_subnet_ngw_usage_type

  vpc_no         = ncloud_vpc.vpc.id
  network_acl_no = ncloud_network_acl.acl.id
}


###############################################################################
#                                     NGW                                     #
###############################################################################
resource "ncloud_nat_gateway" "ngw" {
  name = var.ngw_name
  zone = var.subnet_zone

  vpc_no    = ncloud_vpc.vpc.id
  subnet_no = ncloud_subnet.public_subnet_ngw.id
}


###############################################################################
#                                PUBLIC SUBNET                                #
###############################################################################
resource "ncloud_subnet" "public_subnet" {
  name        = var.public_subnet_name
  zone        = var.subnet_zone
  subnet      = var.public_subnet_cidr_block
  subnet_type = var.public_subnet_type

  vpc_no         = ncloud_vpc.vpc.id
  network_acl_no = ncloud_network_acl.acl.id
}


###############################################################################
#                               PRIVATE SUBNET                                #
###############################################################################
resource "ncloud_subnet" "private_subnets" {
  count = local.create_private_subnets ? local.len_private_subnets : 0

  name        = var.private_subnet_names[count.index]
  zone        = var.subnet_zone
  subnet      = var.private_subnet_cidr_blocks[count.index]
  subnet_type = var.private_subnet_type

  vpc_no         = ncloud_vpc.vpc.id
  network_acl_no = ncloud_network_acl.acl.id
}

data "ncloud_route_table" "selected" {
  vpc_no                = ncloud_vpc.vpc.id
  supported_subnet_type = var.private_subnet_type

  filter {
    name   = "is_default"
    values = ["true"]
  }
}

resource "ncloud_route" "private_route" {
  route_table_no         = data.ncloud_route_table.selected.id
  destination_cidr_block = var.destination_cidr_block

  target_no   = ncloud_nat_gateway.ngw.id
  target_type = "NATGW"
  target_name = ncloud_nat_gateway.ngw.name
}

resource "ncloud_route_table_association" "route_table_assosiations" {
  count = local.create_private_subnets ? local.len_private_subnets : 0

  route_table_no = data.ncloud_route_table.selected.id
  subnet_no      = ncloud_subnet.private_subnets[count.index].id

  depends_on = [ncloud_route.private_route]
}
