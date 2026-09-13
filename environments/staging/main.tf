// Composition root for one environment. Everything environment-specific lives in
// locals.tf and terraform.tfvars; this file is identical across dev, staging and prod.

data "aws_kms_alias" "env" {
  name = "alias/loyaone-${local.environment}"
}

data "terraform_remote_state" "ecr" {
  backend = "s3"
  config = {
    bucket = "loyaone-terraform-state"
    key    = "global/ecr/terraform.tfstate"
    region = var.region
  }
}

// ---------------- Network ----------------
module "vpc" {
  source = "../../modules/vpc"

  name                  = local.name
  vpc_cidr              = local.vpc_cidr
  azs                   = local.azs
  public_subnets_cidrs  = local.public_subnets
  private_subnets_cidrs = local.private_subnets
  enable_nat_gateway    = true
  enable_flow_logs      = local.enable_flow_logs
  kms_key_arn           = data.aws_kms_alias.env.target_key_arn
  tags                  = local.tags
}

module "security_groups" {
  source = "../../modules/security-groups"

  name   = local.name
  vpc_id = module.vpc.vpc_id
  tags   = local.tags
}

// ---------------- Edge ----------------
module "logs_bucket" {
  source = "../../modules/s3"

  bucket_name     = "${local.name}-alb-logs-${data.aws_caller_identity.current.account_id}"
  versioning      = false
  expiration_days = local.alb_log_retention_days
  allow_alb_logs  = true
  force_destroy   = local.environment != "prod"
  tags            = local.tags
}

module "alb" {
  source = "../../modules/alb"

  name                = local.name
  public_subnet_ids   = module.vpc.public_subnet_ids
  security_group_id   = module.security_groups.alb_security_group_id
  certificate_arn     = var.certificate_arn
  deletion_protection = local.environment == "prod"
  access_logs_bucket  = module.logs_bucket.bucket_name
  tags                = local.tags
}

module "waf" {
  count  = local.enable_waf ? 1 : 0
  source = "../../modules/waf"

  name    = local.name
  alb_arn = module.alb.alb_arn
  tags    = local.tags
}

// ---------------- Compute ----------------
module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  name                      = local.name
  vpc_id                    = module.vpc.vpc_id
  default_capacity_provider = local.capacity_provider
  kms_key_arn               = data.aws_kms_alias.env.target_key_arn
  tags                      = local.tags
}

module "nats" {
  source = "../../modules/nats"

  name                             = local.name
  region                           = var.region
  cluster_id                       = module.ecs_cluster.cluster_id
  private_subnet_ids               = module.vpc.private_subnet_ids
  security_group_id                = module.security_groups.nats_security_group_id
  efs_security_group_id            = module.security_groups.efs_security_group_id
  service_discovery_namespace_id   = module.ecs_cluster.service_discovery_namespace_id
  service_discovery_namespace_name = module.ecs_cluster.service_discovery_namespace_name
  enable_backups                   = local.environment == "prod"
  kms_key_arn                      = data.aws_kms_alias.env.target_key_arn
  tags                             = local.tags
}

// ---------------- Data ----------------
module "rds" {
  source = "../../modules/rds"

  name                  = local.name
  private_subnet_ids    = module.vpc.private_subnet_ids
  security_group_id     = module.security_groups.rds_security_group_id
  instance_class        = local.rds_instance_class
  allocated_storage     = local.rds_storage_gb
  multi_az              = local.rds_multi_az
  deletion_protection   = local.environment == "prod"
  backup_retention_days = local.rds_backup_days
  kms_key_arn           = data.aws_kms_alias.env.target_key_arn
  tags                  = local.tags
}

module "redis" {
  source = "../../modules/elasticache"

  name               = local.name
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id  = module.security_groups.redis_security_group_id
  node_type          = local.redis_node_type
  num_cache_clusters = local.redis_nodes
  kms_key_arn        = data.aws_kms_alias.env.target_key_arn
  tags               = local.tags
}

module "idempotency_table" {
  source = "../../modules/dynamodb"

  name                = local.name
  table_name          = "idempotency-keys"
  hash_key            = { name = "key", type = "S" }
  deletion_protection = local.environment == "prod"
  kms_key_arn         = data.aws_kms_alias.env.target_key_arn
  tags                = local.tags
}

module "assets_bucket" {
  source = "../../modules/s3"

  bucket_name   = "${local.name}-assets-${data.aws_caller_identity.current.account_id}"
  force_destroy = local.environment != "prod"
  kms_key_arn   = data.aws_kms_alias.env.target_key_arn
  tags          = local.tags
}

// ---------------- Messaging ----------------
module "queues" {
  source   = "../../modules/sqs"
  for_each = local.queues

  name                       = local.name
  queue_name                 = each.key
  fifo                       = each.value.fifo
  visibility_timeout_seconds = each.value.visibility_timeout
  kms_key_arn                = data.aws_kms_alias.env.target_key_arn
  tags                       = local.tags
}

module "alarms_topic" {
  source = "../../modules/sns"

  name              = local.name
  topic_name        = "alarms"
  email_subscribers = var.alarm_emails
  tags              = local.tags
}

// ---------------- Services ----------------
module "services" {
  source   = "../../modules/ecs-service"
  for_each = var.services

  name                             = local.name
  service_name                     = each.key
  region                           = var.region
  vpc_id                           = module.vpc.vpc_id
  cluster_id                       = module.ecs_cluster.cluster_id
  cluster_name                     = module.ecs_cluster.cluster_name
  private_subnet_ids               = module.vpc.private_subnet_ids
  security_group_id                = module.security_groups.ecs_security_group_id
  service_discovery_namespace_id   = module.ecs_cluster.service_discovery_namespace_id
  service_discovery_namespace_name = module.ecs_cluster.service_discovery_namespace_name

  image          = "${data.terraform_remote_state.ecr.outputs.repository_urls[each.key]}:${each.value.image_tag}"
  container_port = each.value.port
  cpu            = each.value.cpu
  memory         = each.value.memory
  min_count      = each.value.min_count
  max_count      = each.value.max_count
  desired_count  = each.value.min_count

  expose_via_alb         = each.value.expose
  https_listener_arn     = module.alb.https_listener_arn
  listener_rule_priority = each.value.priority
  host_headers           = each.value.host_headers
  path_patterns          = each.value.path_patterns
  capacity_provider      = local.capacity_provider

  environment = merge({
    NODE_ENV          = local.environment
    NATS_URL          = module.nats.nats_url
    REDIS_HOST        = module.redis.primary_endpoint_address
    REDIS_PORT        = tostring(module.redis.port)
    DB_HOST           = module.rds.address
    DB_PORT           = tostring(module.rds.port)
    DB_NAME           = module.rds.database_name
    IDEMPOTENCY_TABLE = module.idempotency_table.table_name
    ASSETS_BUCKET     = module.assets_bucket.bucket_name
  }, each.value.environment)

  // Secrets Manager JSON keys from the RDS-managed secret, plus anything per service.
  secrets = merge({
    DB_USERNAME = "${module.rds.master_user_secret_arn}:username::"
    DB_PASSWORD = "${module.rds.master_user_secret_arn}:password::"
  }, each.value.secrets)

  task_policy_json = data.aws_iam_policy_document.service_permissions[each.key].json
  kms_key_arn      = data.aws_kms_alias.env.target_key_arn
  tags             = local.tags
}

// What every service may call. Extend per service via services[*].extra_policy_arns later.
data "aws_iam_policy_document" "service_permissions" {
  for_each = var.services

  source_policy_documents = concat(
    [module.idempotency_table.readwrite_policy_json],
    [for q in module.queues : q.producer_policy_json],
    [for q in module.queues : q.consumer_policy_json],
  )

  statement {
    sid       = "Assets"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket"]
    resources = [module.assets_bucket.bucket_arn, "${module.assets_bucket.bucket_arn}/*"]
  }
}

// ---------------- Deploy role and alarms ----------------
module "deploy_role" {
  source = "../../modules/iam"

  name                = local.name
  github_repository   = var.github_repository
  github_subjects     = local.github_subjects
  oidc_provider_arn   = var.github_oidc_provider_arn
  ecr_repository_arns = values(data.terraform_remote_state.ecr.outputs.repository_arns)
  tags                = local.tags
}

module "alarms" {
  source = "../../modules/cloudwatch"

  name                       = local.name
  alarm_topic_arn            = module.alarms_topic.topic_arn
  alb_arn_suffix             = module.alb.alb_arn_suffix
  target_group_arn_suffixes  = { for k, s in module.services : k => s.target_group_arn_suffix if s.target_group_arn_suffix != null }
  ecs_cluster_name           = module.ecs_cluster.cluster_name
  ecs_service_names          = [for k, s in module.services : s.service_name]
  rds_instance_identifier    = module.rds.instance_identifier
  redis_replication_group_id = module.redis.replication_group_id
  dlq_names                  = [for q in module.queues : q.dlq_name]
  tags                       = local.tags
}

data "aws_caller_identity" "current" {}
