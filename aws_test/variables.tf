variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "cluster_name" {
  type    = string
  default = "eks-cluster"
}

variable "create_vpc" {
  type    = bool
  default = true
}

variable "vpc_name" {
  type    = string
  default = "vpc-main"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_names" {
  type    = list(string)
  default = ["public-subnet-a", "public-subnet-b"]
}

variable "public_subnet_cidr_blocks" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.10.0/24"]
}

variable "private_subnet_names" {
  type    = list(string)
  default = ["private-subnet-a", "private-subnet-b"]
}

variable "private_subnet_cidr_blocks" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.11.0/24"]
}

variable "create_igw" {
  type    = bool
  default = true
}

variable "create_ngw" {
  type    = bool
  default = true
}

variable "cluster_role_policy_arns" {
  type    = list(string)
  default = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
}

variable "node_role_policy_arns" {
  type    = list(string)
  default = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
}

variable "node_group_name" {
  type    = string
  default = "eks-node-group"
}

variable "node_group_disk_size" {
  type    = string
  default = "20"
}

variable "node_group_instance_types" {
  type    = list(string)
  default = ["t3.small"]
}

variable "node_group_scaling_config" {
  type = object({
    desired_size = number
    min_size     = number
    max_size     = number
  })
  default = {
    desired_size = 1
    min_size     = 1
    max_size     = 3
  }
}

variable "sg_egress" {
  type = object({
    from_port   = string
    to_port     = string
    protocol    = string
    cidr_blocks = list(string)
  })
  default = {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "kubeconfig_filename" {
  type    = string
  default = "kubeconfig"
}
