variable "cluster_name" {
  type = string
}

variable "cluster_role_policy_arns" {
  type = list(string)
}

variable "node_role_policy_arns" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "sg_egress" {
  type = object({
    from_port   = string
    to_port     = string
    protocol    = string
    cidr_blocks = list(string)
  })
}

variable "cluster_subnet_ids" {
  type = list(string)
}

variable "node_group_name" {
  type = string
}

variable "node_group_subnet_ids" {
  type = list(string)
}

variable "node_group_disk_size" {
  type = string
}

variable "node_group_instance_types" {
  type = list(string)
}

variable "node_group_scaling_config" {
  type = object({
    desired_size = number
    min_size     = number
    max_size     = number
  })
}

variable "kubeconfig_filename" {
  type = string
}
