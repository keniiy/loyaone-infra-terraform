
// This wires the dev environment to the vpc module
module "vpc" {
  source = "../../modules/vpc"

  name     = "loyaone-dev"
  vpc_cidr = "10.0.0.0/16"

  // two AZs for dev
  azs = [
    "eu-west-2a",
    "eu-west-2b",
  ]

  // public subnets (for IGW, NAT, maybe load balancers)
  public_subnets_cidrs = [
    "10.0.1.0/24", // public subnet in eu-west-2a
    "10.0.2.0/24", // public subnet in eu-west-2b
  ]

  // private subnets (for EC2, EKS, RDS)
  private_subnets_cidrs = [
    "10.0.11.0/24", // private subnet in eu-west-2a
    "10.0.12.0/24", // private subnet in eu-west-2b
  ]

  enable_nat_gateway = true // dev still needs outbound internet for updates / images

  tags = {
    Project     = "LoyaOne"
    Environment = "dev"
    Owner       = "Kehinde"
  }
}

// expose some outputs so you can quickly see them after apply
output "dev_vpc_id" {
  value = module.vpc.vpc_id
}

output "dev_private_subnets" {
  value = module.vpc.private_subnet_ids
}

output "dev_public_subnets" {
  value = module.vpc.public_subnet_ids
}
