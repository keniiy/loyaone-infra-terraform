variable "name" {
  description = "Environment prefix, e.g. loyaone-dev."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets for the subnet group."
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group for the cluster."
  type        = string
}

variable "engine_version" {
  description = "Redis engine version."
  type        = string
  default     = "7.1"
}

variable "parameter_group_family" {
  description = "Parameter group family matching engine_version."
  type        = string
  default     = "redis7"
}

variable "node_type" {
  description = "Node type, e.g. cache.t4g.small."
  type        = string
  default     = "cache.t4g.small"
}

variable "num_cache_clusters" {
  description = "Number of nodes. 1 for dev, 2 or more for automatic failover."
  type        = number
  default     = 1
}

variable "auth_token" {
  description = "Optional Redis AUTH token (16 to 128 chars). Pass from Secrets Manager, never hardcode."
  type        = string
  default     = null
  sensitive   = true
}

variable "snapshot_retention_days" {
  description = "Days to keep automatic snapshots. 0 disables."
  type        = number
  default     = 1
}

variable "apply_immediately" {
  description = "Apply changes now instead of in the maintenance window."
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Retention for the slow log group."
  type        = number
  default     = 14
}

variable "kms_key_arn" {
  description = "KMS key for at-rest encryption and the log group."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
