terraform {
  backend "s3" {
    bucket  = "test-tf-state-2023-10-17"
    key     = "tf/state"
    region  = "us-west-2"
  }
}
