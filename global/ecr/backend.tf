terraform {
  backend "s3" {
    bucket         = "loyaone-terraform-state"
    key            = "global/ecr/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "loyaone-terraform-locks"
  }
}
