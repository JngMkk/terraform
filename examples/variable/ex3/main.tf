variable "var1" {
  type    = number
  default = 1
}

resource "local_file" "var_level_test" {
  content  = var.var1
  filename = "${path.module}/var_level_test.txt"
}