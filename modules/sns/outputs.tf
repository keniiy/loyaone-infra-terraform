output "topic_arn" {
  description = "Topic ARN."
  value       = aws_sns_topic.this.arn
}

output "publisher_policy_json" {
  description = "IAM policy JSON allowing publish to this topic."
  value       = data.aws_iam_policy_document.publisher.json
}
