# waf

Regional WAF with AWS managed rule groups and a per-IP rate limit, associated to the ALB.

## Usage

```hcl
module "waf" {
  source = "../../modules/waf"
  name = ...
  alb_arn = ...
}
```

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `name` | Environment prefix, e.g. loyaone-prod. | `string` | required |
| `alb_arn` | ALB to protect. | `string` | required |
| `rate_limit_per_5_minutes` | Requests per IP per 5 minutes before blocking. | `number` | `2000` |
| `managed_rule_groups` | AWS managed rule groups to enable, in priority order. | `list(string)` | `(see variables.tf)` |
| `tags` | Tags applied to every resource. | `map(string)` | `{}` |

## Outputs

| Name | Description |
|---|---|
| `web_acl_arn` | Web ACL ARN. |
