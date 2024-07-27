###############################################################################
#                                     VPC                                     #
###############################################################################
variable "vpc_name" {
  type    = string
  default = "test-vpc"
}

variable "vpc_ipv4_cidr_block" {
  type    = string
  default = "172.16.0.0/16"
}


###############################################################################
#                                     ACL                                     #
###############################################################################
variable "acl_name" {
  type    = string
  default = "test-acl"
}


###############################################################################
#                                    SUBNET                                   #
###############################################################################
variable "subnet_zone" {
  type    = string
  default = "KR-1"
}

variable "public_subnet_name" {
  type    = string
  default = "public-subnet-1"
}

variable "public_subnet_cidr_block" {
  type    = string
  default = "172.16.20.0/24"
}

variable "public_subnet_type" {
  type    = string
  default = "PUBLIC"
}

variable "private_subnet_names" {
  type    = list(string)
  default = ["private-subnet-1"]
}

variable "private_subnet_cidr_blocks" {
  type    = list(string)
  default = ["172.16.1.0/24"]
}

variable "private_subnet_type" {
  type    = string
  default = "PRIVATE"
}


###############################################################################
#                                 ROUTE TABLE                                 #
###############################################################################
variable "destination_cidr_block" {
  type    = string
  default = "0.0.0.0/0"
}

variable "private_rt_name" {
  type    = string
  default = "private-rt"
}


###############################################################################
#                                  ALB SUBNET                                 #
###############################################################################
variable "public_subnet_alb_name" {
  type    = string
  default = "public-subnet-lb"
}

variable "public_subnet_alb_cidr_block" {
  type    = string
  default = "172.16.0.0/24"
}

variable "public_subnet_alb_subnet_type" {
  type    = string
  default = "PUBLIC"
}

variable "public_subnet_alb_usage_type" {
  type    = string
  default = "LOADB"
}


###############################################################################
#                                     ALB                                     #
###############################################################################
variable "alb_name" {
  type    = string
  default = "test-alb"
}

variable "alb_network_type" {
  type    = string
  default = "PUBLIC"
}

variable "alb_type" {
  type    = string
  default = "APPLICATION"
}


###############################################################################
#                                  NGW SUBNET                                 #
###############################################################################
variable "public_subnet_ngw_name" {
  type    = string
  default = "public-subnet-ngw"
}

variable "public_subnet_ngw_cidr_block" {
  type    = string
  default = "172.16.10.0/24"
}

variable "public_subnet_ngw_subnet_type" {
  type    = string
  default = "PUBLIC"
}

variable "public_subnet_ngw_usage_type" {
  type    = string
  default = "NATGW"
}


###############################################################################
#                                     NGW                                     #
###############################################################################
variable "ngw_name" {
  type    = string
  default = "test-ngw"
}
