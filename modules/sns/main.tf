// SNS topic with optional email and SQS subscriptions. Used for operational alarms
// and for fan-out of domain events to more than one consumer.

resource "aws_sns_topic" "this" {
  name              = "${var.name}-${var.topic_name}"
  kms_master_key_id = var.kms_key_arn
  tags              = merge(var.tags, { Name = "${var.name}-${var.topic_name}" })
}

resource "aws_sns_topic_subscription" "email" {
  for_each = toset(var.email_subscribers)

  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_sns_topic_subscription" "sqs" {
  for_each = var.sqs_subscriber_arns

  topic_arn            = aws_sns_topic.this.arn
  protocol             = "sqs"
  endpoint             = each.value
  raw_message_delivery = true
}

data "aws_iam_policy_document" "publisher" {
  statement {
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.this.arn]
  }
}
