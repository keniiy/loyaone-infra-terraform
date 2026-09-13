locals {
  environment = "staging"
  name        = "loyaone-staging"

  vpc_cidr        = "10.1.0.0/16"
  azs             = ["eu-west-2a", "eu-west-2b"]
  public_subnets  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets = ["10.1.11.0/24", "10.1.12.0/24"]

  // Mirrors prod topology at smaller sizes so release rehearsals are honest.
  enable_flow_logs       = true
  enable_waf             = false
  capacity_provider      = "FARGATE"
  rds_instance_class     = "db.t4g.small"
  rds_storage_gb         = 50
  rds_multi_az           = false
  rds_backup_days        = 7
  redis_node_type        = "cache.t4g.small"
  redis_nodes            = 2
  alb_log_retention_days = 30

  queues = {
    points-accrual = { fifo = true, visibility_timeout = 60 }
    webhook-retry  = { fifo = false, visibility_timeout = 120 }
  }

  github_subjects = ["ref:refs/heads/main", "environment:staging"]

  tags = {
    Project     = "LoyaOne"
    Environment = local.environment
    ManagedBy   = "terraform"
  }
}
