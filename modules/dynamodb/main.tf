// On-demand DynamoDB table. In LoyaOne this holds idempotency keys and short-lived
// distributed locks, which is why TTL is on by default.

resource "aws_dynamodb_table" "this" {
  name         = "${var.name}-${var.table_name}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.hash_key.name
  range_key    = var.range_key == null ? null : var.range_key.name

  attribute {
    name = var.hash_key.name
    type = var.hash_key.type
  }

  dynamic "attribute" {
    for_each = var.range_key == null ? [] : [var.range_key]
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "ttl" {
    for_each = var.ttl_attribute == null ? [] : [1]
    content {
      attribute_name = var.ttl_attribute
      enabled        = true
    }
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  deletion_protection_enabled = var.deletion_protection

  tags = merge(var.tags, { Name = "${var.name}-${var.table_name}" })
}

data "aws_iam_policy_document" "readwrite" {
  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:ConditionCheckItem",
    ]
    resources = [aws_dynamodb_table.this.arn]
  }
}
