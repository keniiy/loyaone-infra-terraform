# security-groups

Every security group in the platform, wired by group reference so traffic can only flow internet -> ALB -> ECS -> data stores.

## Usage

```hcl
module "security_groups" {
  source = "../../modules/security-groups"
  name = ...
  vpc_id = ...
}
```

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `name` | Name prefix, e.g. loyaone-dev. | `string` | required |
| `vpc_id` | VPC the groups belong to. | `string` | required |
| `container_port_range` | Port range the ALB may reach on ECS tasks. | `object` | `{` |
| `tags` | Tags applied to every resource. | `map(string)` | `{}` |

## Outputs

| Name | Description |
|---|---|
| `alb_security_group_id` | Security group for the ALB. |
| `ecs_security_group_id` | Security group for ECS tasks. |
| `rds_security_group_id` | Security group for RDS. |
| `redis_security_group_id` | Security group for ElastiCache. |
| `nats_security_group_id` | Security group for the NATS task. |
| `efs_security_group_id` | Security group for the NATS EFS mount targets. |
