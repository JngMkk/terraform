module "aws_network" {
  source = "./modules/aws_network"

  cluster_name               = var.cluster_name
  create_vpc                 = var.create_vpc
  vpc_name                   = var.vpc_name
  vpc_cidr_block             = var.vpc_cidr_block
  public_subnet_names        = var.public_subnet_names
  public_subnet_cidr_blocks  = var.public_subnet_cidr_blocks
  private_subnet_names       = var.private_subnet_names
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  create_igw                 = var.create_igw
  create_ngw                 = var.create_ngw
}

module "aws_eks" {
  source = "./modules/aws_eks"

  vpc_id                    = module.aws_network.vpc_id
  cluster_subnet_ids        = concat(module.aws_network.public_sn_ids, module.aws_network.private_sn_ids)
  node_group_subnet_ids     = module.aws_network.private_sn_ids
  cluster_name              = var.cluster_name
  cluster_role_policy_arns  = var.cluster_role_policy_arns
  node_role_policy_arns     = var.node_role_policy_arns
  node_group_name           = var.node_group_name
  node_group_disk_size      = var.node_group_disk_size
  node_group_instance_types = var.node_group_instance_types
  node_group_scaling_config = var.node_group_scaling_config
  sg_egress                 = var.sg_egress
  kubeconfig_filename       = var.kubeconfig_filename
}
