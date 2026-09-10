// One customer-managed key per environment for RDS, ElastiCache, SQS, SNS, S3 and logs.
// Keeping the key global (outside the env stacks) means an env can be destroyed and
// rebuilt without losing the ability to read old encrypted backups and snapshots.

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "key" {
  // Account root keeps full control. Service access is granted through grants
  // and resource policies, not by widening this document.
  statement {
    sid       = "EnableRootPermissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  // Let CloudWatch Logs in this region encrypt log groups with the key.
  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["logs.${var.region}.amazonaws.com"]
    }
    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}

resource "aws_kms_key" "this" {
  for_each = toset(var.environments)

  description             = "LoyaOne ${each.key} data key"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.key.json

  tags = merge(var.tags, { Name = "loyaone-${each.key}", Environment = each.key })
}

resource "aws_kms_alias" "this" {
  for_each = aws_kms_key.this

  name          = "alias/loyaone-${each.key}"
  target_key_id = each.value.key_id
}
