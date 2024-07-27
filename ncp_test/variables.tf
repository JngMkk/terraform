variable "access_key" {
  type      = string
  sensitive = true
}

variable "secret_key" {
  type      = string
  sensitive = true
}

variable "region" {
  type    = string
  default = "KR"
}

variable "support_vpc" {
  type    = bool
  default = true
}

variable "office_ip_block" {
  type      = string
  sensitive = true
}