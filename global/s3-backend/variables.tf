variable "bucket_name" {
  type        = string
  default     = "loyaone-terraform-state"
  description = "s3 bucket name for terraform state"
}

variable "dynamodb_table" {
  type        = string
  default     = "loyaone-terraform-locks"
  description = "dynamodb table name for terraform state locks"
}
