// Every security group the platform needs, wired by reference rather than by CIDR.
// Traffic only flows: internet -> ALB -> ECS tasks -> (RDS | Redis | NATS -> EFS).

resource "aws_security_group" "alb" {
  name        = "${var.name}-alb"
  description = "Public entry point: HTTP and HTTPS from anywhere"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}-alb" })
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTP, redirected to HTTPS at the listener"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTPS"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_all" {
  security_group_id = aws_security_group.alb.id
  description       = "ALB may reach any target"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "ecs" {
  name        = "${var.name}-ecs-tasks"
  description = "ECS tasks: accept only from the ALB and from each other"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}-ecs-tasks" })
}

resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  security_group_id            = aws_security_group.ecs.id
  description                  = "Container ports from the ALB"
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = var.container_port_range.from
  to_port                      = var.container_port_range.to
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ecs_from_ecs" {
  security_group_id            = aws_security_group.ecs.id
  description                  = "Service to service (gRPC, HTTP) inside the cluster"
  referenced_security_group_id = aws_security_group.ecs.id
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_egress_rule" "ecs_all" {
  security_group_id = aws_security_group.ecs.id
  description       = "Outbound to AWS APIs, PSPs and package registries via NAT"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "rds" {
  name        = "${var.name}-rds"
  description = "PostgreSQL from ECS tasks only"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}-rds" })
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_ecs" {
  security_group_id            = aws_security_group.rds.id
  description                  = "PostgreSQL from ECS tasks"
  referenced_security_group_id = aws_security_group.ecs.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_security_group" "redis" {
  name        = "${var.name}-redis"
  description = "Redis from ECS tasks only"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}-redis" })
}

resource "aws_vpc_security_group_ingress_rule" "redis_from_ecs" {
  security_group_id            = aws_security_group.redis.id
  description                  = "Redis from ECS tasks"
  referenced_security_group_id = aws_security_group.ecs.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
}

resource "aws_security_group" "nats" {
  name        = "${var.name}-nats"
  description = "NATS client and monitoring ports from ECS tasks"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}-nats" })
}

resource "aws_vpc_security_group_ingress_rule" "nats_client" {
  security_group_id            = aws_security_group.nats.id
  description                  = "NATS client port"
  referenced_security_group_id = aws_security_group.ecs.id
  from_port                    = 4222
  to_port                      = 4222
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "nats_monitor" {
  security_group_id            = aws_security_group.nats.id
  description                  = "NATS HTTP monitoring"
  referenced_security_group_id = aws_security_group.ecs.id
  from_port                    = 8222
  to_port                      = 8222
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "nats_all" {
  security_group_id = aws_security_group.nats.id
  description       = "NATS may reach EFS and AWS APIs"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "efs" {
  name        = "${var.name}-efs"
  description = "NFS from the NATS task only"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}-efs" })
}

resource "aws_vpc_security_group_ingress_rule" "efs_from_nats" {
  security_group_id            = aws_security_group.efs.id
  description                  = "NFS from NATS"
  referenced_security_group_id = aws_security_group.nats.id
  from_port                    = 2049
  to_port                      = 2049
  ip_protocol                  = "tcp"
}
