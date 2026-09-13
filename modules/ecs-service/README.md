# ecs-service

One HTTP microservice on Fargate: task definition, execution and task roles, log group, ALB target group and rule, service discovery, autoscaling, and a circuit breaker that rolls back bad deploys.

## Usage

```hcl
module "ecs_service" {
  source = "../../modules/ecs-service"
  name = ...
  service_name = ...
  region = ...
  vpc_id = ...
  cluster_id = ...
  cluster_name = ...
  private_subnet_ids = ...
  security_group_id = ...
  service_discovery_namespace_id = ...
  image = ...
  service_discovery_namespace_name = ...
}
```

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `name` | Environment prefix, e.g. loyaone-dev. | `string` | required |
| `service_name` | Short service name, e.g. api, loyalty, merchant. | `string` | required |
| `region` | AWS region, used for the awslogs driver. | `string` | required |
| `vpc_id` | VPC for the target group. | `string` | required |
| `cluster_id` | ECS cluster ID. | `string` | required |
| `cluster_name` | ECS cluster name, used by Application Auto Scaling. | `string` | required |
| `private_subnet_ids` | Private subnets the tasks run in. | `list(string)` | required |
| `security_group_id` | Security group for the tasks. | `string` | required |
| `service_discovery_namespace_id` | Cloud Map namespace ID. | `string` | required |
| `image` | Container image with tag or digest, e.g. 123456789012.dkr.ecr.eu-west-2.amazonaws.com/loyaone/api:1.4.2. | `string` | required |
| `container_port` | Port the container listens on. | `number` | `3000` |
| `cpu` | Fargate CPU units for the task (256, 512, 1024, 2048, 4096). | `number` | `512` |
| `memory` | Fargate memory in MiB, must be valid for the chosen CPU. | `number` | `1024` |
| `cpu_architecture` | X86_64 or ARM64. ARM64 (Graviton) is cheaper for Node.js workloads. | `string` | `"ARM64"` |
| `environment` | Plain environment variables for the container. | `map(string)` | `{}` |
| `secrets` | Map of env var name to Secrets Manager or SSM parameter ARN. Injected at task start. | `map(string)` | `{}` |
| `task_policy_json` | IAM policy JSON granting the running service its AWS permissions (SQS, S3, etc.). Null for none. | `string` | `null` |
| `expose_via_alb` | Attach the service to the shared ALB. False for internal-only workers. | `bool` | `true` |
| `https_listener_arn` | HTTPS listener ARN on the shared ALB. Required when expose_via_alb is true. | `string` | `null` |
| `listener_rule_priority` | Unique priority for this service's listener rule (1 to 50000). | `number` | `100` |
| `host_headers` | Hostnames routed to this service, e.g. [\"api.loyaone.com\"]. | `list(string)` | `[]` |
| `path_patterns` | Path patterns routed to this service, e.g. [\"/v1/loyalty/*\"]. | `list(string)` | `[]` |
| `health_check_path` | HTTP path returning 2xx when the service is healthy. | `string` | `"/health"` |
| `deregistration_delay` | Seconds the ALB drains connections before removing a task. | `number` | `30` |
| `desired_count` | Initial number of tasks. Autoscaling takes over afterwards. | `number` | `1` |
| `min_count` | Autoscaling floor. | `number` | `1` |
| `max_count` | Autoscaling ceiling. | `number` | `4` |
| `cpu_target_utilization` | Target average CPU percent for scaling. | `number` | `60` |
| `memory_target_utilization` | Target average memory percent for scaling. | `number` | `70` |
| `capacity_provider` | FARGATE or FARGATE_SPOT. | `string` | `"FARGATE"` |
| `enable_execute_command` | Allow ECS Exec into this service's tasks. | `bool` | `true` |
| `readonly_root_filesystem` | Mount the container root filesystem read-only. Requires the app to write only to /tmp. | `bool` | `false` |
| `log_retention_days` | CloudWatch log retention. | `number` | `30` |
| `kms_key_arn` | KMS key for the log group and secrets decryption. | `string` | `null` |
| `tags` | Tags applied to every resource. | `map(string)` | `{}` |
| `service_discovery_namespace_name` | Cloud Map namespace name, used to build the discovery hostname output. | `string` | required |

## Outputs

| Name | Description |
|---|---|
| `service_name` | ECS service name. |
| `task_definition_arn` | Task definition ARN currently deployed. |
| `task_role_arn` | IAM role the running service assumes. |
| `target_group_arn_suffix` | Target group ARN suffix for CloudWatch metrics. Null for internal services. |
| `log_group_name` | CloudWatch log group for the service. |
| `discovery_hostname` | Internal hostname other services can use, e.g. api.loyaone-dev.local. |
