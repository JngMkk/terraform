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

module "aws_eks" {
  source = "./modules/aws_eks"

  vpc_id                    = module.aws_network.vpc_id
  cluster_subnet_ids        = concat(module.aws_network.public_sn_ids, module.aws_network.private_sn_ids)
  node_group_subnet_ids     = module.aws_network.private_sn_ids
  cluster_name              = "eks-cluster-test"
  cluster_role_policy_arns  = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
  node_role_policy_arns     = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
  node_group_name           = "eks-test-node-group"
  node_group_disk_size      = "20"
  node_group_instance_types = ["t3.medium"]
  node_group_scaling_config = {
    desired_size = 1
    min_size     = 1
    max_size     = 3
  }
  sg_egress = {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  kubeconfig_filename = "kubeconfig"
}
