output "alb_security_group_id" {
  description = "Security group for the ALB."
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "Security group for ECS tasks."
  value       = aws_security_group.ecs.id
}

output "rds_security_group_id" {
  description = "Security group for RDS."
  value       = aws_security_group.rds.id
}

output "redis_security_group_id" {
  description = "Security group for ElastiCache."
  value       = aws_security_group.redis.id
}

output "nats_security_group_id" {
  description = "Security group for the NATS task."
  value       = aws_security_group.nats.id
}

output "efs_security_group_id" {
  description = "Security group for the NATS EFS mount targets."
  value       = aws_security_group.efs.id
}
