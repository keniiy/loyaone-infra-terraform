output "queue_url" {
  description = "Queue URL."
  value       = aws_sqs_queue.this.id
}

output "queue_arn" {
  description = "Queue ARN."
  value       = aws_sqs_queue.this.arn
}

output "queue_name" {
  description = "Queue name, used by CloudWatch alarms."
  value       = aws_sqs_queue.this.name
}

output "dlq_arn" {
  description = "Dead-letter queue ARN."
  value       = aws_sqs_queue.dlq.arn
}

output "dlq_name" {
  description = "Dead-letter queue name, used by CloudWatch alarms."
  value       = aws_sqs_queue.dlq.name
}

output "consumer_policy_json" {
  description = "IAM policy JSON for a consumer. Attach to the consuming service's task role."
  value       = data.aws_iam_policy_document.consumer.json
}

output "producer_policy_json" {
  description = "IAM policy JSON for a producer."
  value       = data.aws_iam_policy_document.producer.json
}
