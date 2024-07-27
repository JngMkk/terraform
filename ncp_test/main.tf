module "ncp_network" {
  source = "./modules/ncp_network"
}

module "ncp_server" {
  source = "./modules/ncp_server"

  vpc_id            = module.ncp_network.vpc_id
  office_ip_block   = var.office_ip_block
  public_subnet_id  = module.ncp_network.public_subnet_id
  private_subnet_id = module.ncp_network.private_subnet_ids[0]
}
