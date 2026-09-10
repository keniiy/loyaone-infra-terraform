locals {
  environment = "dev"
  name        = "loyaone-dev"

  vpc_cidr        = "10.0.0.0/16"
  azs             = ["eu-west-2a", "eu-west-2b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

  // Cheap and disposable.
  enable_flow_logs       = false
  enable_waf             = false
  capacity_provider      = "FARGATE_SPOT"
  rds_instance_class     = "db.t4g.micro"
  rds_storage_gb         = 20
  rds_multi_az           = false
  rds_backup_days        = 1
  redis_node_type        = "cache.t4g.micro"
  redis_nodes            = 1
  alb_log_retention_days = 7

  queues = {
    points-accrual = { fifo = true, visibility_timeout = 60 }
    webhook-retry  = { fifo = false, visibility_timeout = 120 }
  }

  github_subjects = ["ref:refs/heads/*", "environment:dev"]

  tags = {
    Project     = "LoyaOne"
    Environment = local.environment
    ManagedBy   = "terraform"
  }
}
