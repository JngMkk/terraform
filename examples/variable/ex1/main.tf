variable "str" {
  type        = string
  description = "string"
  default     = "This is str value."
}

variable "num" {
  type    = number
  default = 123
}

variable "tf" {
  type    = bool
  default = true
}

variable "lst" {
  type = list(string)
  default = [
    "google",
    "vmware",
    "amazon",
    "microsoft"
  ]
}

output "lst_index_0" {
  value = var.lst.0
}

output "lst_all" {
  value = [
    for name in var.lst :
    upper(name)
  ]
}

variable "mapp" {
  type = map(string)
  default = { # sorting
    aws   = "amazon",
    azure = "microsoft",
    gcp   = "google"
  }
}

variable "sett" {
  type = set(string)
  default = [ # sorting
    "google",
    "vmware",
    "amazon",
    "microsoft"
  ]
}

variable "obj" {
  type = object({ name = string, age = number })
  default = {
    name = "KJM"
    age  = 111
  }
}

variable "tup" {
  type    = tuple([string, number, bool])
  default = ["KJM", 111, false]
}

variable "ingress_rules" {
  type = list(
    object(
      { port = number, description = optional(string), protocol = optional(string, "tcp") }
    )
  )
  default = [
    { port = 80, description = "http" },
    { port = 53, protocol = "udp" }
  ]
}

variable "image_id" {
  type = string
  description = "The ID of the machine image."

  validation {
    condition = length(var.image_id) > 4
    error_message = "The image_id value must be greater than 4."
  }

  validation {
    # regex
    condition = can(regex("^ami-", var.image_id))
    error_message = "The image_id value must starting with \"ami-\"."
  }
}
