terraform {
  backend "s3" {
    bucket       = "loyaone-terraform-state"
    key          = "global/s3-backend/terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
    encrypt      = true
  }
}
