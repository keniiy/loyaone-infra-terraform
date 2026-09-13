# elasticache

Redis replication group, encrypted at rest and in transit, LRU eviction, slow log to CloudWatch, automatic failover when more than one node.

## Usage

```hcl
module "elasticache" {
  source = "../../modules/elasticache"
  name = ...
  private_subnet_ids = ...
  security_group_id = ...
}
```

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `name` | Environment prefix, e.g. loyaone-dev. | `string` | required |
| `private_subnet_ids` | Private subnets for the subnet group. | `list(string)` | required |
| `security_group_id` | Security group for the cluster. | `string` | required |
| `engine_version` | Redis engine version. | `string` | `"7.1"` |
| `parameter_group_family` | Parameter group family matching engine_version. | `string` | `"redis7"` |
| `node_type` | Node type, e.g. cache.t4g.small. | `string` | `"cache.t4g.small"` |
| `num_cache_clusters` | Number of nodes. 1 for dev, 2 or more for automatic failover. | `number` | `1` |
| `auth_token` | Optional Redis AUTH token (16 to 128 chars). Pass from Secrets Manager, never hardcode. | `string` | `null` |
| `snapshot_retention_days` | Days to keep automatic snapshots. 0 disables. | `number` | `1` |
| `apply_immediately` | Apply changes now instead of in the maintenance window. | `bool` | `false` |
| `log_retention_days` | Retention for the slow log group. | `number` | `14` |
| `kms_key_arn` | KMS key for at-rest encryption and the log group. | `string` | `null` |
| `tags` | Tags applied to every resource. | `map(string)` | `{}` |

## Outputs

| Name | Description |
|---|---|
| `primary_endpoint_address` | Primary endpoint hostname for writes. |
| `reader_endpoint_address` | Reader endpoint hostname. |
| `port` | Redis port. |
| `replication_group_id` | Replication group ID, used by CloudWatch alarms. |
