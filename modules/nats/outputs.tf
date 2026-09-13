output "nats_url" {
  description = "Connection URL for services in the same namespace."
  value       = "nats://nats.${var.service_discovery_namespace_name}:4222"
}

output "efs_file_system_id" {
  description = "EFS file system backing JetStream."
  value       = aws_efs_file_system.this.id
}

output "log_group_name" {
  description = "CloudWatch log group for NATS."
  value       = aws_cloudwatch_log_group.this.name
}
