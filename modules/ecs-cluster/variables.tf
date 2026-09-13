variable "name" {
  description = "Cluster name, e.g. loyaone-dev."
  type        = string
}

variable "vpc_id" {
  description = "VPC for the private DNS namespace."
  type        = string
}

variable "container_insights" {
  description = "Enable CloudWatch Container Insights."
  type        = bool
  default     = true
}

variable "enable_execute_command" {
  description = "Allow ECS Exec (shell into a running task) with encrypted, logged sessions."
  type        = bool
  default     = true
}

variable "default_capacity_provider" {
  description = "FARGATE or FARGATE_SPOT."
  type        = string
  default     = "FARGATE"
  validation {
    condition     = contains(["FARGATE", "FARGATE_SPOT"], var.default_capacity_provider)
    error_message = "default_capacity_provider must be FARGATE or FARGATE_SPOT."
  }
}

variable "log_retention_days" {
  description = "Retention for the ECS Exec log group."
  type        = number
  default     = 30
}

variable "kms_key_arn" {
  description = "KMS key for the ECS Exec log group."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
