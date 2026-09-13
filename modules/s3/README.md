# s3

Private, versioned, encrypted bucket with public access blocked, TLS enforced and lifecycle housekeeping. Can accept ALB access logs.

## Usage

```hcl
module "s3" {
  source = "../../modules/s3"
  bucket_name = ...
}
```

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `bucket_name` | Globally unique bucket name. | `string` | required |
| `versioning` | Keep previous object versions. | `bool` | `true` |
| `noncurrent_version_expiration_days` | Days to keep non-current versions. | `number` | `30` |
| `expiration_days` | Expire current objects after this many days. Null keeps them forever. | `number` | `null` |
| `force_destroy` | Allow destroy even when the bucket has objects. Dev only. | `bool` | `false` |
| `allow_alb_logs` | Grant the regional ELB service account write access for ALB access logs. | `bool` | `false` |
| `kms_key_arn` | KMS key for encryption. Null uses SSE-S3. Must be null when allow_alb_logs is true. | `string` | `null` |
| `tags` | Tags applied to every resource. | `map(string)` | `{}` |

## Outputs

| Name | Description |
|---|---|
| `bucket_name` | Bucket name. |
| `bucket_arn` | Bucket ARN. |
| `bucket_domain_name` | Bucket regional domain name. |
