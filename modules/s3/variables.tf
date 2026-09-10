variable "bucket_name" {
  description = "Globally unique bucket name."
  type        = string
}

variable "versioning" {
  description = "Keep previous object versions."
  type        = bool
  default     = true
}

variable "noncurrent_version_expiration_days" {
  description = "Days to keep non-current versions."
  type        = number
  default     = 30
}

variable "expiration_days" {
  description = "Expire current objects after this many days. Null keeps them forever."
  type        = number
  default     = null
}

variable "force_destroy" {
  description = "Allow destroy even when the bucket has objects. Dev only."
  type        = bool
  default     = false
}

variable "allow_alb_logs" {
  description = "Grant the regional ELB service account write access for ALB access logs."
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "KMS key for encryption. Null uses SSE-S3. Must be null when allow_alb_logs is true."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
