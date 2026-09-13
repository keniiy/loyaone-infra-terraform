variable "region" {
  description = "AWS region."
  type        = string
  default     = "eu-west-2"
}

variable "services" {
  description = "Service names, one repository each."
  type        = list(string)
  default     = ["api", "loyalty", "merchant", "notification"]
}

variable "tags" {
  description = "Tags applied to every repository."
  type        = map(string)
  default = {
    Project   = "LoyaOne"
    ManagedBy = "terraform"
    Scope     = "global"
  }
}
