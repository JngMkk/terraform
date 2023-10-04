variable "password" {
  default   = "Passw0rd"
  sensitive = true
}

resource "local_file" "pw" {
  content  = var.password
  filename = "${path.module}/pw.txt"
}
