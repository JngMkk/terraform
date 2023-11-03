variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "cluster_name" {
  type    = string
  default = "eks-cluster"
}

variable "kube_system_namespace" {
  type    = string
  default = "kube-system"
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

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "template_file_path" {
  type    = string
  default = "./modules/aws_eks/userdata.tpl"
}
