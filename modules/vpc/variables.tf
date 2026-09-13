variable "name" {
  description = "Name prefix for every resource, e.g. loyaone-dev."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC, e.g. 10.0.0.0/16."
  type        = string
}

variable "azs" {
  description = "Availability zones to spread subnets across. One subnet per AZ per tier."
  type        = list(string)
}

variable "public_subnets_cidrs" {
  description = "CIDR blocks for public subnets. Must be the same length as azs."
  type        = list(string)
}

variable "private_subnets_cidrs" {
  description = "CIDR blocks for private subnets. Must be the same length as azs."
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Create a NAT gateway so private subnets have outbound internet access."
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Send VPC flow logs to CloudWatch."
  type        = bool
  default     = false
}

variable "flow_logs_retention_days" {
  description = "Retention for the flow log group."
  type        = number
  default     = 30
}

variable "kms_key_arn" {
  description = "KMS key used to encrypt the flow log group. Null uses the CloudWatch default."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
