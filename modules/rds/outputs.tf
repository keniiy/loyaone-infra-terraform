output "endpoint" {
  description = "host:port for the primary instance."
  value       = aws_db_instance.this.endpoint
}

output "address" {
  description = "Hostname of the primary instance."
  value       = aws_db_instance.this.address
}

output "port" {
  description = "Port."
  value       = aws_db_instance.this.port
}

output "database_name" {
  description = "Initial database name."
  value       = aws_db_instance.this.db_name
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN holding the master credentials. Reference it from ECS task secrets."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}

output "instance_identifier" {
  description = "RDS instance identifier, used by CloudWatch alarms."
  value       = aws_db_instance.this.identifier
}

output "instance_arn" {
  description = "RDS instance ARN."
  value       = aws_db_instance.this.arn
}
