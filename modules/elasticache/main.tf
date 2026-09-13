// Redis (ElastiCache) for caching, rate limits and idempotency keys.
// Encrypted at rest and in transit; multi-node with automatic failover when asked.

locals {
  full_name = "${var.name}-redis"
}

resource "aws_elasticache_subnet_group" "this" {
  name       = local.full_name
  subnet_ids = var.private_subnet_ids
  tags       = merge(var.tags, { Name = local.full_name })
}

resource "aws_elasticache_parameter_group" "this" {
  name   = local.full_name
  family = var.parameter_group_family

  // Evict least-recently-used keys under memory pressure rather than refusing writes.
  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "slow" {
  name              = "/loyaone/${var.name}/redis-slow-log"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn
  tags              = var.tags
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = local.full_name
  description          = "LoyaOne ${var.name} Redis"

  engine               = "redis"
  engine_version       = var.engine_version
  node_type            = var.node_type
  port                 = 6379
  parameter_group_name = aws_elasticache_parameter_group.this.name

  num_cache_clusters         = var.num_cache_clusters
  automatic_failover_enabled = var.num_cache_clusters > 1
  multi_az_enabled           = var.num_cache_clusters > 1

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = [var.security_group_id]

  at_rest_encryption_enabled = true
  kms_key_id                 = var.kms_key_arn
  transit_encryption_enabled = true
  auth_token                 = var.auth_token
  auth_token_update_strategy = var.auth_token == null ? null : "ROTATE"

  snapshot_retention_limit = var.snapshot_retention_days
  snapshot_window          = "01:00-02:00"
  maintenance_window       = "sun:04:30-sun:05:30"

  auto_minor_version_upgrade = true
  apply_immediately          = var.apply_immediately

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.slow.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }

  tags = merge(var.tags, { Name = local.full_name })
}
