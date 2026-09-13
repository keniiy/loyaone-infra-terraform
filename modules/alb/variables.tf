variable "name" {
  description = "Name prefix, e.g. loyaone-dev."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets the ALB is placed in (at least two AZs)."
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group for the ALB."
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the HTTPS listener."
  type        = string
}

variable "additional_certificate_arns" {
  description = "Extra ACM certificates for additional hostnames."
  type        = list(string)
  default     = []
}

variable "ssl_policy" {
  description = "TLS policy for the HTTPS listener."
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "deletion_protection" {
  description = "Prevent accidental deletion of the ALB. On in prod."
  type        = bool
  default     = false
}

variable "idle_timeout" {
  description = "Idle timeout in seconds. Keep above the longest PSP callback you expect."
  type        = number
  default     = 60
}

variable "access_logs_bucket" {
  description = "S3 bucket for ALB access logs. Null disables access logging."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
