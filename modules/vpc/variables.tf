variable "name" {
  description = "Name prefix for the VPC and all network resources"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC (the overall IP range)"
  type        = string
}

variable "azs" {
  description = "List of availability zones to spread subnets across"
  type        = list(string)
}

variable "public_subnets_cidrs" {
  description = "List of CIDR blocks for the public subnets (One per AZ)"
  type        = list(string)
}

variable "private_subnets_cidrs" {
  description = "List of CIDR blocks for the private subnets (One per AZ)"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to create a single NAT gateway for private subnets"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
