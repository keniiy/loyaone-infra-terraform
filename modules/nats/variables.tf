variable "name" {
  description = "Environment prefix, e.g. loyaone-dev."
  type        = string
}

variable "region" {
  description = "AWS region for the awslogs driver."
  type        = string
}

variable "cluster_id" {
  description = "ECS cluster ID."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets for the task and EFS mount targets."
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group for the NATS task."
  type        = string
}

variable "efs_security_group_id" {
  description = "Security group for the EFS mount targets."
  type        = string
}

variable "service_discovery_namespace_id" {
  description = "Cloud Map namespace ID."
  type        = string
}

variable "image" {
  description = "NATS server image."
  type        = string
  default     = "nats:2.11-alpine"
}

variable "cpu" {
  description = "Fargate CPU units."
  type        = number
  default     = 512
}

variable "memory" {
  description = "Fargate memory in MiB."
  type        = number
  default     = 1024
}

variable "max_memory_store" {
  description = "JetStream in-memory store limit."
  type        = string
  default     = "256M"
}

variable "max_file_store" {
  description = "JetStream file store limit on EFS."
  type        = string
  default     = "10G"
}

variable "enable_backups" {
  description = "Enable AWS Backup for the EFS file system."
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention."
  type        = number
  default     = 30
}

variable "kms_key_arn" {
  description = "KMS key for EFS and the log group."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}

variable "service_discovery_namespace_name" {
  description = "Cloud Map namespace name, used for the nats_url output."
  type        = string
}
