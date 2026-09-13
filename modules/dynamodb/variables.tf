variable "name" {
  description = "Environment prefix, e.g. loyaone-dev."
  type        = string
}

variable "table_name" {
  description = "Table purpose, e.g. idempotency-keys."
  type        = string
}

variable "hash_key" {
  description = "Partition key name and type (S, N or B)."
  type = object({
    name = string
    type = string
  })
}

variable "range_key" {
  description = "Optional sort key name and type."
  type = object({
    name = string
    type = string
  })
  default = null
}

variable "ttl_attribute" {
  description = "Attribute holding the epoch expiry. Null disables TTL."
  type        = string
  default     = "expires_at"
}

variable "point_in_time_recovery" {
  description = "Enable PITR backups."
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Block table deletion. On in prod."
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "KMS key for encryption. Null uses the AWS-owned key."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
