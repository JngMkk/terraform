variable "prefix" {
  default = "Hello"
}

locals {
  name = "terraform"
  content = "${var.prefix} ${local.name}"
  info = {
    age = 20, region = "KR"
  }
  nums = [1, 2, 3, 4, 5]
}

locals {
  content = "content2"      # 중복 선언되었으므로 오류 발생
}
