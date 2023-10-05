module "mypw1" {
  source = "./modules/password"
}

module "mypw2" {
  source = "./modules/password"
  isDB   = true
}
