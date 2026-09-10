// A queue plus its dead-letter queue. Messages that fail max_receive_count times
// land in the DLQ instead of being retried forever.

resource "aws_sqs_queue" "dlq" {
  name                      = "${var.name}-${var.queue_name}-dlq"
  message_retention_seconds = var.dlq_retention_seconds
  kms_master_key_id         = var.kms_key_arn
  sqs_managed_sse_enabled   = var.kms_key_arn == null ? true : null
  tags                      = merge(var.tags, { Name = "${var.name}-${var.queue_name}-dlq" })
}

resource "aws_sqs_queue" "this" {
  name                        = "${var.name}-${var.queue_name}${var.fifo ? ".fifo" : ""}"
  fifo_queue                  = var.fifo
  content_based_deduplication = var.fifo ? var.content_based_deduplication : null
  visibility_timeout_seconds  = var.visibility_timeout_seconds
  message_retention_seconds   = var.retention_seconds
  receive_wait_time_seconds   = var.receive_wait_time_seconds
  kms_master_key_id           = var.kms_key_arn
  sqs_managed_sse_enabled     = var.kms_key_arn == null ? true : null

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = merge(var.tags, { Name = "${var.name}-${var.queue_name}" })
}

resource "aws_sqs_queue_redrive_allow_policy" "dlq" {
  queue_url = aws_sqs_queue.dlq.id
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.this.arn]
  })
}

// Consumer and producer policies to attach to ECS task roles.
data "aws_iam_policy_document" "consumer" {
  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:ChangeMessageVisibility",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
    ]
    resources = [aws_sqs_queue.this.arn]
  }
}

data "aws_iam_policy_document" "producer" {
  statement {
    actions   = ["sqs:SendMessage", "sqs:GetQueueUrl"]
    resources = [aws_sqs_queue.this.arn]
  }
}
