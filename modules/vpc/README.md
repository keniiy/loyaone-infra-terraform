# vpc

VPC with public and private subnets across N availability zones, an internet gateway, an optional NAT gateway and optional flow logs.

## Usage

```hcl
module "vpc" {
  source = "../../modules/vpc"
  name = ...
  vpc_cidr = ...
  azs = ...
  public_subnets_cidrs = ...
  private_subnets_cidrs = ...
}
```

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `name` | Name prefix for every resource, e.g. loyaone-dev. | `string` | required |
| `vpc_cidr` | CIDR block for the VPC, e.g. 10.0.0.0/16. | `string` | required |
| `azs` | Availability zones to spread subnets across. One subnet per AZ per tier. | `list(string)` | required |
| `public_subnets_cidrs` | CIDR blocks for public subnets. Must be the same length as azs. | `list(string)` | required |
| `private_subnets_cidrs` | CIDR blocks for private subnets. Must be the same length as azs. | `list(string)` | required |
| `enable_nat_gateway` | Create a NAT gateway so private subnets have outbound internet access. | `bool` | `true` |
| `enable_flow_logs` | Send VPC flow logs to CloudWatch. | `bool` | `false` |
| `flow_logs_retention_days` | Retention for the flow log group. | `number` | `30` |
| `kms_key_arn` | KMS key used to encrypt the flow log group. Null uses the CloudWatch default. | `string` | `null` |
| `tags` | Tags applied to every resource. | `map(string)` | `{}` |

## Outputs

| Name | Description |
|---|---|
| `vpc_id` | VPC ID. |
| `vpc_cidr` | VPC CIDR block. |
| `public_subnet_ids` | List of public subnet IDs. |
| `private_subnet_ids` | List of private subnet IDs. |
| `public_route_table_id` | Public route table ID. |
| `private_route_table_id` | Private route table ID. |
| `nat_gateway_public_ip` | Elastic IP of the NAT gateway, for allow-listing with third parties (e.g. a PSP). Null when NAT is disabled. |
