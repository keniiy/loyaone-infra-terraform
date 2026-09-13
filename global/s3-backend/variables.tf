variable "state_bucket_name" {
  description = "Globally unique name of the S3 bucket that stores Terraform state."
  type        = string
  default     = "loyaone-terraform-state"
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table used for state locking."
  type        = string
  default     = "loyaone-terraform-locks"
}

variable "kms_key_arn" {
  description = "Optional KMS key ARN for encrypting state. Leave null to use SSE-S3 (AES256)."
  type        = string
  default     = null
}

variable "noncurrent_version_expiration_days" {
  description = "Days to retain non-current state versions before expiring them."
  type        = number
  default     = 90
}

variable "tags" {
  description = "Tags applied to every resource in this stack."
  type        = map(string)
  default = {
    Project   = "LoyaOne"
    ManagedBy = "terraform"
    Scope     = "global"
  }
}

variable "region" {
  description = "AWS region for the state bucket and lock table."
  type        = string
  default     = "eu-west-2"
}
