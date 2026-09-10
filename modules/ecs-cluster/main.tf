// One Fargate cluster per environment with Container Insights and ECS Exec enabled.

resource "aws_kms_key" "exec" {
  count = var.enable_execute_command ? 1 : 0

  description             = "${var.name} ECS Exec session encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_cloudwatch_log_group" "exec" {
  count = var.enable_execute_command ? 1 : 0

  name              = "/loyaone/${var.name}/ecs-exec"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn
  tags              = var.tags
}

resource "aws_ecs_cluster" "this" {
  name = var.name

  setting {
    name  = "containerInsights"
    value = var.container_insights ? "enabled" : "disabled"
  }

  dynamic "configuration" {
    for_each = var.enable_execute_command ? [1] : []
    content {
      execute_command_configuration {
        kms_key_id = aws_kms_key.exec[0].arn
        logging    = "OVERRIDE"
        log_configuration {
          cloud_watch_encryption_enabled = true
          cloud_watch_log_group_name     = aws_cloudwatch_log_group.exec[0].name
        }
      }
    }
  }

  tags = merge(var.tags, { Name = var.name })
}

// Spot for dev and staging, on-demand for prod, expressed as a default weighting
// that each service can override.
resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = var.default_capacity_provider
    weight            = 1
    base              = 1
  }
}

// Private DNS so services find each other by name (e.g. nats.loyaone-dev.local).
resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = "${var.name}.local"
  description = "Service discovery for ${var.name}"
  vpc         = var.vpc_id
  tags        = var.tags
}
