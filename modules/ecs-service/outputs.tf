output "service_name" {
  description = "ECS service name."
  value       = aws_ecs_service.this.name
}

output "task_definition_arn" {
  description = "Task definition ARN currently deployed."
  value       = aws_ecs_task_definition.this.arn
}

output "task_role_arn" {
  description = "IAM role the running service assumes."
  value       = aws_iam_role.task.arn
}

output "target_group_arn_suffix" {
  description = "Target group ARN suffix for CloudWatch metrics. Null for internal services."
  value       = var.expose_via_alb ? aws_lb_target_group.this[0].arn_suffix : null
}

output "log_group_name" {
  description = "CloudWatch log group for the service."
  value       = aws_cloudwatch_log_group.this.name
}

output "discovery_hostname" {
  description = "Internal hostname other services can use, e.g. api.loyaone-dev.local."
  value       = "${var.service_name}.${var.service_discovery_namespace_name}"
}
