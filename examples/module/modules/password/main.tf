resource "random_pet" "rp" {
  keepers = {
    ami_id = timestamp()
  }
}

resource "random_password" "pw" {
  length           = var.isDB ? 16 : 10
  special          = var.isDB ? true : false
  override_special = "!#$%*?"
}
