module "aws_network" {
  source = "./modules/aws_network"

  create_vpc                 = true
  vpc_name                   = "test-vpc"
  vpc_cidr_block             = "10.0.0.0/16"
  public_subnet_names        = ["public-subnet-a", "public-subnet-b"]
  public_subnet_cidr_blocks  = ["10.0.0.0/24", "10.0.10.0/24"]
  private_subnet_names       = ["private-subnet-a", "private-subnet-b"]
  private_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.11.0/24"]
  create_igw                 = true
  create_ngw                 = true
}
