variable "name" {
  description = "Environment prefix, e.g. loyaone-dev."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets for the DB subnet group (two AZs minimum)."
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group for the instance."
  type        = string
}

variable "engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "16.6"
}

variable "parameter_group_family" {
  description = "Parameter group family matching engine_version."
  type        = string
  default     = "postgres16"
}

variable "instance_class" {
  description = "Instance class, e.g. db.t4g.medium."
  type        = string
  default     = "db.t4g.medium"
}

variable "allocated_storage" {
  description = "Initial storage in GiB."
  type        = number
  default     = 50
}

variable "max_allocated_storage" {
  description = "Storage autoscaling ceiling in GiB."
  type        = number
  default     = 200
}

variable "database_name" {
  description = "Initial database name."
  type        = string
  default     = "loyaone"
}

variable "master_username" {
  description = "Master username. Password is managed by Secrets Manager."
  type        = string
  default     = "loyaone_admin"
}

variable "multi_az" {
  description = "Run a standby in a second AZ. On in prod."
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Automated backup retention in days."
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Block deletion and take a final snapshot on destroy. On in prod."
  type        = bool
  default     = false
}

variable "performance_insights" {
  description = "Enable Performance Insights."
  type        = bool
  default     = true
}

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0 disables)."
  type        = number
  default     = 60
}

variable "slow_query_threshold_ms" {
  description = "Queries slower than this are logged."
  type        = number
  default     = 500
}

variable "apply_immediately" {
  description = "Apply changes now instead of in the maintenance window."
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "KMS key for storage, the master secret and Performance Insights."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
