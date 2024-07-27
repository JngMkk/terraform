terraform {
  required_version = "~> 1.9.0"

  required_providers {
    ncloud = {
      source  = "NaverCloudPlatform/ncloud"
      version = "3.1.1"
    }
  }
}