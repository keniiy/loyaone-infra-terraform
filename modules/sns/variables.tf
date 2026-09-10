variable "name" {
  description = "Environment prefix, e.g. loyaone-dev."
  type        = string
}

variable "topic_name" {
  description = "Topic purpose, e.g. alarms, loyalty-events."
  type        = string
}

variable "email_subscribers" {
  description = "Email addresses to subscribe (each must confirm)."
  type        = list(string)
  default     = []
}

variable "sqs_subscriber_arns" {
  description = "Map of label to SQS queue ARN to subscribe."
  type        = map(string)
  default     = {}
}

variable "kms_key_arn" {
  description = "KMS key for encryption. Null uses the SNS default."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
