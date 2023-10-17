locals {
  create_vpc = var.create_vpc
  vpc_name   = var.vpc_name
  vpc_id     = try(aws_vpc.vpc[0].id, "")

  len_public_subnets     = length(var.public_subnet_cidr_blocks)
  len_private_subnets    = length(var.private_subnet_cidr_blocks)
  create_public_subnets  = local.create_vpc && local.len_public_subnets > 0
  create_private_subnets = local.create_vpc && local.len_private_subnets > 0

  nat_gateway_ips = try(aws_eip.eips[*].id, [])
}


data "aws_availability_zones" "azs" {
  state = "available"
}


#####################################################################
#                                VPC                                #
#####################################################################
resource "aws_vpc" "vpc" {
  count = local.create_vpc ? 1 : 0

  # ! CidrBlock 혹은 Ipv4IpamPoolId를 반드시 지정해야 함
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  instance_tenancy     = var.instance_tenancy

  tags = {
    Name = "${local.vpc_name}"
  }
}


#####################################################################
#                         Internet GateWay                          #
#####################################################################
resource "aws_internet_gateway" "igw" {
  /*
  VPC와 인터넷 간 통신할 수 있도록 할당
  리소스에 퍼블릿 IPv4 주소 또는 IPv6 주소가 있는 경우 인터넷 게이트웨이를 사용하면 퍼블릿 서브넷의 리소스가 인터넷에 연결할 수 있음
  */

  count = local.create_public_subnets && var.create_igw ? 1 : 0

  # 인터넷 게이트웨이 또는 가상 프라이빗 게이트웨이를 VPC에 연결하여 인터넷과 VPC 간의 연결을 활성화
  vpc_id = local.vpc_id

  tags = {
    Name = "${local.vpc_name}-igw"
  }
}


#####################################################################
#                              Subnets                              #
#####################################################################
resource "aws_subnet" "public_subnets" {
  count = local.create_public_subnets ? local.len_public_subnets : 0

  vpc_id                  = local.vpc_id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name = "${local.vpc_name}-${var.public_subnet_names[count.index]}"
  }
}

resource "aws_route_table" "public_route_table" {
  count = local.create_public_subnets ? 1 : 0

  vpc_id = local.vpc_id

  route {
    cidr_block = var.rt_cidr_block
    gateway_id = aws_internet_gateway.igw[0].id
  }

  tags = {
    Name = "${local.vpc_name}-public-rt"
  }
}

resource "aws_route_table_association" "public_sn_association" {
  count = local.create_public_subnets ? local.len_public_subnets : 0

  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_route_table[0].id
}

resource "aws_subnet" "private_subnets" {
  count = local.create_private_subnets ? local.len_private_subnets : 0

  vpc_id            = local.vpc_id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = {
    Name = "${local.vpc_name}-${var.private_subnet_names[count.index]}"
  }
}

resource "aws_eip" "eips" {
  count = var.create_ngw && local.create_private_subnets ? local.len_private_subnets : 0

  domain = var.eip_domain

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "ngws" {
  /*
  Public NAT Gateway를 생성하는 경우 Elastic IP 주소를 지정해야 함
  NAT Gateway를 사용하면 프라이빗 서브넷의 인스턴스가 NAT Gateway의 IP 주소를 사용하여
  인터넷, 다른 AWS 서비스 또는 온프레미스 네트워크에 연결할 수 있음
  NAT Gateway를 가리키는 기본 경로(AWS::EC2::Route Resource)를 추가하는 경우 경로의 NatGatewayId 속성에 NAT Gateway ID를 지정
  EIP 주소 또는 Secondary EIP 주소를 Public NAT Gateway와 연결하는 경우 EIP 주소의 네트워크 경계 그룹은 NAT Gateway가 있는 AZ의 네트워크 경계 그룹과 일치해야 함
  그렇지 않으면 NAT Gateway가 시작되지 않음
  */
  count = var.create_ngw && local.create_private_subnets ? local.len_public_subnets : 0

  allocation_id = element(local.nat_gateway_ips, count.index) # NAT Gateway와 연결된 EIP 주소 할당 ID (Public NAT Gateway만 해당)
  subnet_id     = element(aws_subnet.public_subnets[*].id, count.index)

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private_route_tables" {
  count = local.create_private_subnets ? local.len_private_subnets : 0

  vpc_id = local.vpc_id

  route {
    cidr_block     = var.rt_cidr_block
    nat_gateway_id = element(aws_nat_gateway.ngws[*].id, count.index)
  }

  tags = {
    Name = "${local.vpc_id}-${var.private_subnet_names[count.index]}-rt"
  }
}

resource "aws_route_table_association" "private_sn_association" {
  count = local.create_private_subnets ? local.len_private_subnets : 0

  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = element(aws_route_table.private_route_tables[*].id, count.index)
}
