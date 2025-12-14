terraform {
  backend "s3" {
    bucket         = "loyaone-terraform-state"
    key            = "envs/dev/terraform.tfstate"
    region         = "eu-west-2"
    use_lockfile   = true
    encrypt        = true
    dynamodb_table = "loyaone-terraform-locks"
  }
}

