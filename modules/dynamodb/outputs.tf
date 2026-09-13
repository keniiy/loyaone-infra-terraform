output "table_name" {
  description = "Table name."
  value       = aws_dynamodb_table.this.name
}

output "table_arn" {
  description = "Table ARN."
  value       = aws_dynamodb_table.this.arn
}

output "readwrite_policy_json" {
  description = "IAM policy JSON for read/write access. Attach to a task role."
  value       = data.aws_iam_policy_document.readwrite.json
}
