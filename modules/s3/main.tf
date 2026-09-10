// Private, versioned, encrypted bucket. Used for merchant assets, exports and ALB logs.

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
  tags          = merge(var.tags, { Name = var.bucket_name })
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_arn == null ? "AES256" : "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = var.kms_key_arn != null
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "housekeeping"
    status = "Enabled"
    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    dynamic "noncurrent_version_expiration" {
      for_each = var.versioning ? [1] : []
      content {
        noncurrent_days = var.noncurrent_version_expiration_days
      }
    }

    dynamic "expiration" {
      for_each = var.expiration_days == null ? [] : [1]
      content {
        days = var.expiration_days
      }
    }
  }
}

// Deny plaintext access. ALB log delivery, when enabled, is added on top.
data "aws_elb_service_account" "this" {
  count = var.allow_alb_logs ? 1 : 0
}

data "aws_iam_policy_document" "this" {
  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [aws_s3_bucket.this.arn, "${aws_s3_bucket.this.arn}/*"]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  dynamic "statement" {
    for_each = var.allow_alb_logs ? [1] : []
    content {
      sid     = "AllowAlbLogDelivery"
      effect  = "Allow"
      actions = ["s3:PutObject"]
      principals {
        type        = "AWS"
        identifiers = [data.aws_elb_service_account.this[0].arn]
      }
      resources = ["${aws_s3_bucket.this.arn}/*"]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this.json

  depends_on = [aws_s3_bucket_public_access_block.this]
}
