# rds

PostgreSQL on RDS with a Secrets Manager-managed master password, gp3 encrypted storage, slow-query logging, optional Multi-AZ, Performance Insights and enhanced monitoring.

## Usage

```hcl
module "rds" {
  source = "../../modules/rds"
  name = ...
  private_subnet_ids = ...
  security_group_id = ...
}
```

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `name` | Environment prefix, e.g. loyaone-dev. | `string` | required |
| `private_subnet_ids` | Private subnets for the DB subnet group (two AZs minimum). | `list(string)` | required |
| `security_group_id` | Security group for the instance. | `string` | required |
| `engine_version` | PostgreSQL engine version. | `string` | `"16.6"` |
| `parameter_group_family` | Parameter group family matching engine_version. | `string` | `"postgres16"` |
| `instance_class` | Instance class, e.g. db.t4g.medium. | `string` | `"db.t4g.medium"` |
| `allocated_storage` | Initial storage in GiB. | `number` | `50` |
| `max_allocated_storage` | Storage autoscaling ceiling in GiB. | `number` | `200` |
| `database_name` | Initial database name. | `string` | `"loyaone"` |
| `master_username` | Master username. Password is managed by Secrets Manager. | `string` | `"loyaone_admin"` |
| `multi_az` | Run a standby in a second AZ. On in prod. | `bool` | `false` |
| `backup_retention_days` | Automated backup retention in days. | `number` | `7` |
| `deletion_protection` | Block deletion and take a final snapshot on destroy. On in prod. | `bool` | `false` |
| `performance_insights` | Enable Performance Insights. | `bool` | `true` |
| `monitoring_interval` | Enhanced monitoring interval in seconds (0 disables). | `number` | `60` |
| `slow_query_threshold_ms` | Queries slower than this are logged. | `number` | `500` |
| `apply_immediately` | Apply changes now instead of in the maintenance window. | `bool` | `false` |
| `kms_key_arn` | KMS key for storage, the master secret and Performance Insights. | `string` | `null` |
| `tags` | Tags applied to every resource. | `map(string)` | `{}` |

## Outputs

| Name | Description |
|---|---|
| `endpoint` | host:port for the primary instance. |
| `address` | Hostname of the primary instance. |
| `port` | Port. |
| `database_name` | Initial database name. |
| `master_user_secret_arn` | Secrets Manager ARN holding the master credentials. Reference it from ECS task secrets. |
| `instance_identifier` | RDS instance identifier, used by CloudWatch alarms. |
| `instance_arn` | RDS instance ARN. |
