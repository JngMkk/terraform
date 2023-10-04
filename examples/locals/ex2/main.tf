variable "prefix" {
  default = "hello"
}

locals {
  name = "terraform"
}

resource "local_file" "hello_tf" {
  content  = local.content
  filename = "${path.module}/hello_tf.txt"
}