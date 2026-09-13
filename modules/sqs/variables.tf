variable "name" {
  description = "Environment prefix, e.g. loyaone-dev."
  type        = string
}

variable "queue_name" {
  description = "Queue purpose, e.g. points-accrual, webhook-retry."
  type        = string
}

variable "fifo" {
  description = "Create a FIFO queue (ordering + exactly-once within a group)."
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "For FIFO queues, dedupe on message body hash."
  type        = bool
  default     = true
}

variable "visibility_timeout_seconds" {
  description = "How long a message is hidden after receipt. Set above the consumer's processing time."
  type        = number
  default     = 60
}

variable "retention_seconds" {
  description = "Message retention (max 14 days)."
  type        = number
  default     = 345600
}

variable "dlq_retention_seconds" {
  description = "DLQ retention (default 14 days)."
  type        = number
  default     = 1209600
}

variable "receive_wait_time_seconds" {
  description = "Long polling wait time."
  type        = number
  default     = 20
}

variable "max_receive_count" {
  description = "Receives before a message moves to the DLQ."
  type        = number
  default     = 5
}

variable "kms_key_arn" {
  description = "KMS key for encryption. Null uses SQS-managed keys."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
