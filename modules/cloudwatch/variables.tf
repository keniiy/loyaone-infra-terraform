variable "name" {
  description = "Environment prefix, e.g. loyaone-dev."
  type        = string
}

variable "alarm_topic_arn" {
  description = "SNS topic that receives every alarm and OK notification."
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix."
  type        = string
}

variable "target_group_arn_suffixes" {
  description = "Map of service name to target group ARN suffix for unhealthy-host alarms."
  type        = map(string)
  default     = {}
}

variable "ecs_cluster_name" {
  description = "ECS cluster name."
  type        = string
}

variable "ecs_service_names" {
  description = "ECS services to alarm on CPU and memory."
  type        = list(string)
  default     = []
}

variable "rds_instance_identifier" {
  description = "RDS instance identifier."
  type        = string
}

variable "redis_replication_group_id" {
  description = "ElastiCache replication group ID."
  type        = string
}

variable "dlq_names" {
  description = "Dead-letter queue names to alarm on."
  type        = list(string)
  default     = []
}

variable "alb_5xx_threshold" {
  description = "ALB 5xx count per 5 minutes before alarming."
  type        = number
  default     = 10
}

variable "target_5xx_threshold" {
  description = "Target 5xx count per 5 minutes before alarming."
  type        = number
  default     = 25
}

variable "ecs_cpu_threshold" {
  description = "ECS service CPU percent."
  type        = number
  default     = 85
}

variable "ecs_memory_threshold" {
  description = "ECS service memory percent."
  type        = number
  default     = 85
}

variable "rds_cpu_threshold" {
  description = "RDS CPU percent."
  type        = number
  default     = 80
}

variable "rds_free_storage_threshold_gb" {
  description = "RDS free storage floor in GiB."
  type        = number
  default     = 10
}

variable "rds_connections_threshold" {
  description = "RDS connection count ceiling."
  type        = number
  default     = 150
}

variable "redis_cpu_threshold" {
  description = "Redis engine CPU percent."
  type        = number
  default     = 80
}

variable "redis_evictions_threshold" {
  description = "Redis evictions per 5 minutes before alarming."
  type        = number
  default     = 100
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
