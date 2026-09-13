output "state_bucket_name" {
  description = "Name of the state bucket. Use in every environment backend.tf."
  value       = aws_s3_bucket.state.id
}

output "state_bucket_arn" {
  description = "ARN of the state bucket."
  value       = aws_s3_bucket.state.arn
}

output "lock_table_name" {
  description = "Name of the DynamoDB lock table. Use in every environment backend.tf."
  value       = aws_dynamodb_table.locks.name
}
