# ecs-cluster

Fargate cluster with Container Insights, encrypted ECS Exec, Spot/on-demand capacity providers and a Cloud Map namespace for service discovery.

## Usage

```hcl
module "ecs_cluster" {
  source = "../../modules/ecs-cluster"
  name = ...
  vpc_id = ...
}
```

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `name` | Cluster name, e.g. loyaone-dev. | `string` | required |
| `vpc_id` | VPC for the private DNS namespace. | `string` | required |
| `container_insights` | Enable CloudWatch Container Insights. | `bool` | `true` |
| `enable_execute_command` | Allow ECS Exec (shell into a running task) with encrypted, logged sessions. | `bool` | `true` |
| `default_capacity_provider` | FARGATE or FARGATE_SPOT. | `string` | `"FARGATE"` |
| `log_retention_days` | Retention for the ECS Exec log group. | `number` | `30` |
| `kms_key_arn` | KMS key for the ECS Exec log group. | `string` | `null` |
| `tags` | Tags applied to every resource. | `map(string)` | `{}` |

## Outputs

| Name | Description |
|---|---|
| `cluster_id` | ECS cluster ID. |
| `cluster_name` | ECS cluster name. |
| `cluster_arn` | ECS cluster ARN. |
| `service_discovery_namespace_id` | Cloud Map namespace ID for service discovery. |
| `service_discovery_namespace_name` | Cloud Map namespace name, e.g. loyaone-dev.local. |
