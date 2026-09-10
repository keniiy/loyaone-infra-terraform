# cloudwatch

The alarms on-call actually wants: ALB and target 5xx, unhealthy hosts, ECS CPU and memory, RDS CPU, storage and connections, Redis CPU and evictions, DLQ depth.

## Usage

```hcl
module "cloudwatch" {
  source = "../../modules/cloudwatch"
  name = ...
  alarm_topic_arn = ...
  alb_arn_suffix = ...
  ecs_cluster_name = ...
  rds_instance_identifier = ...
  redis_replication_group_id = ...
}
```

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `name` | Environment prefix, e.g. loyaone-dev. | `string` | required |
| `alarm_topic_arn` | SNS topic that receives every alarm and OK notification. | `string` | required |
| `alb_arn_suffix` | ALB ARN suffix. | `string` | required |
| `target_group_arn_suffixes` | Map of service name to target group ARN suffix for unhealthy-host alarms. | `map(string)` | `{}` |
| `ecs_cluster_name` | ECS cluster name. | `string` | required |
| `ecs_service_names` | ECS services to alarm on CPU and memory. | `list(string)` | `[]` |
| `rds_instance_identifier` | RDS instance identifier. | `string` | required |
| `redis_replication_group_id` | ElastiCache replication group ID. | `string` | required |
| `dlq_names` | Dead-letter queue names to alarm on. | `list(string)` | `[]` |
| `alb_5xx_threshold` | ALB 5xx count per 5 minutes before alarming. | `number` | `10` |
| `target_5xx_threshold` | Target 5xx count per 5 minutes before alarming. | `number` | `25` |
| `ecs_cpu_threshold` | ECS service CPU percent. | `number` | `85` |
| `ecs_memory_threshold` | ECS service memory percent. | `number` | `85` |
| `rds_cpu_threshold` | RDS CPU percent. | `number` | `80` |
| `rds_free_storage_threshold_gb` | RDS free storage floor in GiB. | `number` | `10` |
| `rds_connections_threshold` | RDS connection count ceiling. | `number` | `150` |
| `redis_cpu_threshold` | Redis engine CPU percent. | `number` | `80` |
| `redis_evictions_threshold` | Redis evictions per 5 minutes before alarming. | `number` | `100` |
| `tags` | Tags applied to every resource. | `map(string)` | `{}` |

## Outputs

| Name | Description |
|---|---|
| `alarm_names` | Every alarm created, for dashboards or runbooks. |
