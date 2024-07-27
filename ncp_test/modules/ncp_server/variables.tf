variable "vpc_id" {}

variable "public_subnet_id" {}

variable "private_subnet_id" {}

variable "office_ip_block" {}


###############################################################################
#                                     ACG                                     #
###############################################################################
variable "bastion_acg_name" {
  type    = string
  default = "bastion-acg"
}


###############################################################################
#                                   SERVER                                    #
###############################################################################
variable "bastion_server_name" {
  type    = string
  default = "bastion"
}

variable "servers" {
  type = list(object({
    name                = string
    server_product_code = string
    use_init_script     = bool
    env_tag             = string
  }))
  default = [
    # ! 아직 ncp terraform api에서 지원하지 않음. 일단 콘솔에서 생성
    # { name = "bastion", server_product_code = "", use_init_script = false },
    { name = "devops", server_product_code = "SVR.VSVR.CPU.C002.M004.NET.SSD.B050.G002", use_init_script = true, env_tag = "devops" },
    { name = "dev-1", server_product_code = "SVR.VSVR.CPU.C002.M004.NET.SSD.B050.G002", use_init_script = true, env_tag = "dev" },
    { name = "prod-1", server_product_code = "SVR.VSVR.CPU.C002.M004.NET.SSD.B050.G002", use_init_script = true, env_tag = "prod" },
  ]
}
