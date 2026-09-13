variable "region" {
  description = "AWS region the keys live in."
  type        = string
  default     = "eu-west-2"
}

variable "environments" {
  description = "Environments that get their own KMS key."
  type        = list(string)
  default     = ["dev", "staging", "prod"]
}

variable "deletion_window_in_days" {
  description = "Waiting period before a scheduled key deletion completes."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags applied to every key."
  type        = map(string)
  default = {
    Project   = "LoyaOne"
    ManagedBy = "terraform"
    Scope     = "global"
  }
}
