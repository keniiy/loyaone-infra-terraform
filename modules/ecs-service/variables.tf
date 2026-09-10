variable "name" {
  description = "Environment prefix, e.g. loyaone-dev."
  type        = string
}

variable "service_name" {
  description = "Short service name, e.g. api, loyalty, merchant."
  type        = string
}

variable "region" {
  description = "AWS region, used for the awslogs driver."
  type        = string
}

variable "vpc_id" {
  description = "VPC for the target group."
  type        = string
}

variable "cluster_id" {
  description = "ECS cluster ID."
  type        = string
}

variable "cluster_name" {
  description = "ECS cluster name, used by Application Auto Scaling."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets the tasks run in."
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group for the tasks."
  type        = string
}

variable "service_discovery_namespace_id" {
  description = "Cloud Map namespace ID."
  type        = string
}

variable "image" {
  description = "Container image with tag or digest, e.g. 123456789012.dkr.ecr.eu-west-2.amazonaws.com/loyaone/api:1.4.2."
  type        = string
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number
  default     = 3000
}

variable "cpu" {
  description = "Fargate CPU units for the task (256, 512, 1024, 2048, 4096)."
  type        = number
  default     = 512
}

variable "memory" {
  description = "Fargate memory in MiB, must be valid for the chosen CPU."
  type        = number
  default     = 1024
}

variable "cpu_architecture" {
  description = "X86_64 or ARM64. ARM64 (Graviton) is cheaper for Node.js workloads."
  type        = string
  default     = "ARM64"
  validation {
    condition     = contains(["X86_64", "ARM64"], var.cpu_architecture)
    error_message = "cpu_architecture must be X86_64 or ARM64."
  }
}

variable "environment" {
  description = "Plain environment variables for the container."
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Map of env var name to Secrets Manager or SSM parameter ARN. Injected at task start."
  type        = map(string)
  default     = {}
}

variable "task_policy_json" {
  description = "IAM policy JSON granting the running service its AWS permissions (SQS, S3, etc.). Null for none."
  type        = string
  default     = null
}

variable "expose_via_alb" {
  description = "Attach the service to the shared ALB. False for internal-only workers."
  type        = bool
  default     = true
}

variable "https_listener_arn" {
  description = "HTTPS listener ARN on the shared ALB. Required when expose_via_alb is true."
  type        = string
  default     = null
}

variable "listener_rule_priority" {
  description = "Unique priority for this service's listener rule (1 to 50000)."
  type        = number
  default     = 100
}

variable "host_headers" {
  description = "Hostnames routed to this service, e.g. [\"api.loyaone.com\"]."
  type        = list(string)
  default     = []
}

variable "path_patterns" {
  description = "Path patterns routed to this service, e.g. [\"/v1/loyalty/*\"]."
  type        = list(string)
  default     = []
}

variable "health_check_path" {
  description = "HTTP path returning 2xx when the service is healthy."
  type        = string
  default     = "/health"
}

variable "deregistration_delay" {
  description = "Seconds the ALB drains connections before removing a task."
  type        = number
  default     = 30
}

variable "desired_count" {
  description = "Initial number of tasks. Autoscaling takes over afterwards."
  type        = number
  default     = 1
}

variable "min_count" {
  description = "Autoscaling floor."
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Autoscaling ceiling."
  type        = number
  default     = 4
}

variable "cpu_target_utilization" {
  description = "Target average CPU percent for scaling."
  type        = number
  default     = 60
}

variable "memory_target_utilization" {
  description = "Target average memory percent for scaling."
  type        = number
  default     = 70
}

variable "capacity_provider" {
  description = "FARGATE or FARGATE_SPOT."
  type        = string
  default     = "FARGATE"
}

variable "enable_execute_command" {
  description = "Allow ECS Exec into this service's tasks."
  type        = bool
  default     = true
}

variable "readonly_root_filesystem" {
  description = "Mount the container root filesystem read-only. Requires the app to write only to /tmp."
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention."
  type        = number
  default     = 30
}

variable "kms_key_arn" {
  description = "KMS key for the log group and secrets decryption."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}

variable "service_discovery_namespace_name" {
  description = "Cloud Map namespace name, used to build the discovery hostname output."
  type        = string
}
