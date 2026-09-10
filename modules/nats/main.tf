// NATS JetStream as a single Fargate task with EFS-backed persistence, reachable
// at nats.<namespace>:4222 via Cloud Map. One node is enough for LoyaOne's
// current volume; clustering (3 nodes, routes on 6222) is the documented next step.

locals {
  full_name = "${var.name}-nats"
}

// ---- Persistent storage for JetStream streams ----
resource "aws_efs_file_system" "this" {
  creation_token   = local.full_name
  encrypted        = true
  kms_key_id       = var.kms_key_arn
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = merge(var.tags, { Name = local.full_name })
}

resource "aws_efs_mount_target" "this" {
  count = length(var.private_subnet_ids)

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [var.efs_security_group_id]
}

resource "aws_efs_access_point" "this" {
  file_system_id = aws_efs_file_system.this.id

  posix_user {
    uid = 1000
    gid = 1000
  }

  root_directory {
    path = "/jetstream"
    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = "0755"
    }
  }

  tags = merge(var.tags, { Name = local.full_name })
}

resource "aws_efs_backup_policy" "this" {
  file_system_id = aws_efs_file_system.this.id
  backup_policy {
    status = var.enable_backups ? "ENABLED" : "DISABLED"
  }
}

// ---- Logs and IAM ----
resource "aws_cloudwatch_log_group" "this" {
  name              = "/loyaone/${var.name}/nats"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn
  tags              = var.tags
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution" {
  name               = "${local.full_name}-exec"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  name               = "${local.full_name}-task"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "task" {
  statement {
    sid = "MountEfs"
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
    ]
    resources = [aws_efs_file_system.this.arn]
    condition {
      test     = "StringEquals"
      variable = "elasticfilesystem:AccessPointArn"
      values   = [aws_efs_access_point.this.arn]
    }
  }
}

resource "aws_iam_role_policy" "task" {
  name   = "efs-access"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.task.json
}

// ---- Task definition ----
resource "aws_ecs_task_definition" "this" {
  family                   = local.full_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  volume {
    name = "jetstream"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.this.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.this.id
        iam             = "ENABLED"
      }
    }
  }

  container_definitions = jsonencode([
    {
      name      = "nats"
      image     = var.image
      essential = true
      command = [
        "--jetstream",
        "--store_dir", "/data/jetstream",
        "--max_memory_store", var.max_memory_store,
        "--max_file_store", var.max_file_store,
        "--http_port", "8222",
        "--name", local.full_name,
      ]
      portMappings = [
        { containerPort = 4222, hostPort = 4222, protocol = "tcp" },
        { containerPort = 8222, hostPort = 8222, protocol = "tcp" },
      ]
      mountPoints = [{
        sourceVolume  = "jetstream"
        containerPath = "/data/jetstream"
        readOnly      = false
      }]
      healthCheck = {
        command     = ["CMD-SHELL", "wget -qO- http://localhost:8222/healthz || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 30
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = merge(var.tags, { Name = local.full_name })
}

// ---- Discovery and service ----
resource "aws_service_discovery_service" "this" {
  name = "nats"

  dns_config {
    namespace_id   = var.service_discovery_namespace_id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = var.tags
}

resource "aws_ecs_service" "this" {
  name                   = "nats"
  cluster                = var.cluster_id
  task_definition        = aws_ecs_task_definition.this.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  platform_version       = "LATEST"
  enable_execute_command = true
  propagate_tags         = "SERVICE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.this.arn
  }

  // A single JetStream node must never run twice against the same store.
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  tags = merge(var.tags, { Name = local.full_name })

  depends_on = [aws_efs_mount_target.this]
}
