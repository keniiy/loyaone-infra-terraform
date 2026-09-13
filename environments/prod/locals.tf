locals {
  environment = "prod"
  name        = "loyaone-prod"

  vpc_cidr        = "10.2.0.0/16"
  azs             = ["eu-west-2a", "eu-west-2b"]
  public_subnets  = ["10.2.1.0/24", "10.2.2.0/24"]
  private_subnets = ["10.2.11.0/24", "10.2.12.0/24"]

  // Availability over cost: on-demand Fargate, Multi-AZ Postgres, two Redis nodes,
  // WAF in front of the ALB, and retention long enough to answer a dispute.
  enable_flow_logs       = true
  enable_waf             = true
  capacity_provider      = "FARGATE"
  rds_instance_class     = "db.r6g.large"
  rds_storage_gb         = 100
  rds_multi_az           = true
  rds_backup_days        = 30
  redis_node_type        = "cache.r6g.large"
  redis_nodes            = 2
  alb_log_retention_days = 90

  queues = {
    points-accrual = { fifo = true, visibility_timeout = 60 }
    webhook-retry  = { fifo = false, visibility_timeout = 120 }
  }

  // Only the main branch, and only through the protected prod environment, may deploy here.
  github_subjects = ["ref:refs/heads/main", "environment:prod"]

  tags = {
    Project     = "LoyaOne"
    Environment = local.environment
    ManagedBy   = "terraform"
  }
}
