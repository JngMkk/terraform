variable "cluster_name" {
  type = string
}

#####################################################################
#                                VPC                                #
#####################################################################
variable "create_vpc" {
  type = bool
}

variable "vpc_name" {
  type    = string
  default = "test-vpc"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16" # VPC의 IPv4 네트워크 범위
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "instance_tenancy" {
  type    = string
  default = "default"
}


#####################################################################
#                              Subnets                              #
#####################################################################
variable "public_subnet_names" {
  type = list(string)
}

variable "public_subnet_cidr_blocks" {
  type = list(string)
}

variable "private_subnet_names" {
  type = list(string)
}

variable "private_subnet_cidr_blocks" {
  type = list(string)
}

variable "map_public_ip_on_launch" {
  type    = bool
  default = true # 이 서브넷에서 시작된 인스턴스가 퍼블릭 IPv4 주소를 수신하는지 여부
}


#####################################################################
#                         Internet GateWay                          #
#####################################################################
variable "create_igw" {
  type    = bool
  default = true
}


#####################################################################
#                            Route Table                            #
#####################################################################
variable "rt_cidr_block" {
  type    = string
  default = "0.0.0.0/0"
}


#####################################################################
#                            NAT Gateway                            #
#####################################################################
variable "create_ngw" {
  type    = bool
  default = true
}

variable "eip_domain" {
  type    = string
  default = "vpc"
}
