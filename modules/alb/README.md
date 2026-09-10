# alb

Public application load balancer: HTTP redirects to HTTPS, TLS 1.3 policy, fixed 404 default so unknown hosts never reach a service.

## Usage

```hcl
module "alb" {
  source = "../../modules/alb"
  name = ...
  public_subnet_ids = ...
  security_group_id = ...
  certificate_arn = ...
}
```

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `name` | Name prefix, e.g. loyaone-dev. | `string` | required |
| `public_subnet_ids` | Public subnets the ALB is placed in (at least two AZs). | `list(string)` | required |
| `security_group_id` | Security group for the ALB. | `string` | required |
| `certificate_arn` | ACM certificate ARN for the HTTPS listener. | `string` | required |
| `additional_certificate_arns` | Extra ACM certificates for additional hostnames. | `list(string)` | `[]` |
| `ssl_policy` | TLS policy for the HTTPS listener. | `string` | `"ELBSecurityPolicy-TLS13-1-2-2021-06"` |
| `deletion_protection` | Prevent accidental deletion of the ALB. On in prod. | `bool` | `false` |
| `idle_timeout` | Idle timeout in seconds. Keep above the longest PSP callback you expect. | `number` | `60` |
| `access_logs_bucket` | S3 bucket for ALB access logs. Null disables access logging. | `string` | `null` |
| `tags` | Tags applied to every resource. | `map(string)` | `{}` |

## Outputs

| Name | Description |
|---|---|
| `alb_arn` | ALB ARN. |
| `alb_arn_suffix` | ALB ARN suffix, used by CloudWatch metrics. |
| `alb_dns_name` | Public DNS name. Point Route 53 or your DNS provider at this. |
| `alb_zone_id` | Hosted zone ID of the ALB for alias records. |
| `https_listener_arn` | HTTPS listener ARN. Services attach listener rules here. |
