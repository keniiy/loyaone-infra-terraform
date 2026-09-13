# dynamodb

On-demand table with TTL, PITR and encryption. Used for idempotency keys and short-lived locks.

## Usage

```hcl
module "dynamodb" {
  source = "../../modules/dynamodb"
  name = ...
  table_name = ...
  hash_key = ...
}
```

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `name` | Environment prefix, e.g. loyaone-dev. | `string` | required |
| `table_name` | Table purpose, e.g. idempotency-keys. | `string` | required |
| `hash_key` | Partition key name and type (S, N or B). | `object` | required |
| `range_key` | Optional sort key name and type. | `object` | `null` |
| `ttl_attribute` | Attribute holding the epoch expiry. Null disables TTL. | `string` | `"expires_at"` |
| `point_in_time_recovery` | Enable PITR backups. | `bool` | `true` |
| `deletion_protection` | Block table deletion. On in prod. | `bool` | `false` |
| `kms_key_arn` | KMS key for encryption. Null uses the AWS-owned key. | `string` | `null` |
| `tags` | Tags applied to every resource. | `map(string)` | `{}` |

## Outputs

| Name | Description |
|---|---|
| `table_name` | Table name. |
| `table_arn` | Table ARN. |
| `readwrite_policy_json` | IAM policy JSON for read/write access. Attach to a task role. |
