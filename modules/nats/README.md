# nats

NATS JetStream on Fargate with EFS-backed persistence, reachable as nats.<namespace>:4222.

## Usage

```hcl
module "nats" {
  source = "../../modules/nats"
  name = ...
  region = ...
  cluster_id = ...
  private_subnet_ids = ...
  security_group_id = ...
  efs_security_group_id = ...
  service_discovery_namespace_id = ...
  service_discovery_namespace_name = ...
}
```

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `name` | Environment prefix, e.g. loyaone-dev. | `string` | required |
| `region` | AWS region for the awslogs driver. | `string` | required |
| `cluster_id` | ECS cluster ID. | `string` | required |
| `private_subnet_ids` | Private subnets for the task and EFS mount targets. | `list(string)` | required |
| `security_group_id` | Security group for the NATS task. | `string` | required |
| `efs_security_group_id` | Security group for the EFS mount targets. | `string` | required |
| `service_discovery_namespace_id` | Cloud Map namespace ID. | `string` | required |
| `image` | NATS server image. | `string` | `"nats:2.11-alpine"` |
| `cpu` | Fargate CPU units. | `number` | `512` |
| `memory` | Fargate memory in MiB. | `number` | `1024` |
| `max_memory_store` | JetStream in-memory store limit. | `string` | `"256M"` |
| `max_file_store` | JetStream file store limit on EFS. | `string` | `"10G"` |
| `enable_backups` | Enable AWS Backup for the EFS file system. | `bool` | `true` |
| `log_retention_days` | CloudWatch log retention. | `number` | `30` |
| `kms_key_arn` | KMS key for EFS and the log group. | `string` | `null` |
| `tags` | Tags applied to every resource. | `map(string)` | `{}` |
| `service_discovery_namespace_name` | Cloud Map namespace name, used for the nats_url output. | `string` | required |

## Outputs

| Name | Description |
|---|---|
| `nats_url` | Connection URL for services in the same namespace. |
| `efs_file_system_id` | EFS file system backing JetStream. |
| `log_group_name` | CloudWatch log group for NATS. |
