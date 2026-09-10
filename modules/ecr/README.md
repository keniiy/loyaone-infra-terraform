# ecr

One repository per service with immutable tags, scan on push and a lifecycle policy.

## Usage

```hcl
module "ecr" {
  source = "../../modules/ecr"
  repositories = ...
}
```

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `namespace` | Repository prefix, e.g. loyaone. | `string` | `"loyaone"` |
| `repositories` | Service names to create repositories for. | `list(string)` | required |
| `keep_last_images` | Tagged images to retain per repository. | `number` | `30` |
| `force_delete` | Delete repositories even if they contain images. Dev only. | `bool` | `false` |
| `kms_key_arn` | KMS key for image encryption. Null uses AES256. | `string` | `null` |
| `tags` | Tags applied to every resource. | `map(string)` | `{}` |

## Outputs

| Name | Description |
|---|---|
| `repository_urls` | Map of service name to repository URL. |
| `repository_arns` | Map of service name to repository ARN. |
