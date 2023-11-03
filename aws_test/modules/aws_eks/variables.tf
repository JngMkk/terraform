variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "template_file_path" {
  type = string
}

variable "key_name" {
  type    = string
  default = "test-admin"
}

variable "sg_bastion" {
  type    = string
  default = "bastion-sg"
}

variable "bastion" {
  type    = string
  default = "bastion"
}

variable "sg_bastion_ingress_rules" {
  type = object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  })

  default = {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["14.38.93.171/32"]
  }
}

variable "bastion_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "eks_management_policy_name" {
  type    = string
  default = "eks-management"
}

variable "ops_group_name" {
  type    = string
  default = "ops-group"
}

variable "public_sn_ids" {
  type = list(string)
}

variable "private_sn_ids" {
  type = list(string)
}

variable "cluster_role_policy_arns" {
  type    = list(string)
  default = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
}

variable "node_role_policy_arns" {
  type    = list(string)
  default = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
}

variable "sg_egress" {
  type = object({
    from_port   = string
    to_port     = string
    protocol    = string
    cidr_blocks = list(string)
  })
}

variable "ngs" {
  type = list(object({
    template_name = string
    instance_type = string
    ng_name       = string
    desired_size  = number
    min_size      = number
    max_size      = number
    role          = string
  }))
  default = [
    {
      template_name = "dev-template"
      instance_type = "t3.medium"
      ng_name       = "dev-workers"
      desired_size  = 3
      min_size      = 3
      max_size      = 5
      role          = "dev"
    },
    {
      template_name = "prod-template"
      instance_type = "t3.medium"
      ng_name       = "prod-workers"
      desired_size  = 3
      min_size      = 3
      max_size      = 5
      role          = "prod"
    },
    {
      template_name = "devops-template"
      instance_type = "t3.small"
      ng_name       = "devops-workers"
      desired_size  = 1
      min_size      = 1
      max_size      = 1
      role          = "devops"
    }
  ]
}

variable "cluster_addons" {
  type = any
  default = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }
}

variable "namespace" {
  type = string
}

variable "aws_node" {
  type    = string
  default = "aws-node"
}

variable "oidc_config_name" {
  type    = string
  default = "oidc_config"
}
