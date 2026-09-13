output "cluster_id" {
  description = "ECS cluster ID."
  value       = aws_ecs_cluster.this.id
}

output "cluster_name" {
  description = "ECS cluster name."
  value       = aws_ecs_cluster.this.name
}

output "cluster_arn" {
  description = "ECS cluster ARN."
  value       = aws_ecs_cluster.this.arn
}

output "service_discovery_namespace_id" {
  description = "Cloud Map namespace ID for service discovery."
  value       = aws_service_discovery_private_dns_namespace.this.id
}

output "service_discovery_namespace_name" {
  description = "Cloud Map namespace name, e.g. loyaone-dev.local."
  value       = aws_service_discovery_private_dns_namespace.this.name
}
