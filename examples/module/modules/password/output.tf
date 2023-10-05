output "id" {
  value = random_pet.rp.id
}

output "pw" {
  value = nonsensitive(random_password.pw.result)
}

/*
id = "tops-lion"
pw = "f0ax%hOuvAowtOar"
*/
