# LoyaOne infrastructure (Terraform, AWS)

Infrastructure as code for [LoyaOne](https://loyaone.com), the card-linked loyalty
platform built at Reeddi. NestJS microservices on ECS Fargate behind one ALB, with
PostgreSQL, Redis, NATS JetStream, SQS and DynamoDB, in three environments.

> **PICK ONE, then delete this note.**
> (a) This repository defines the live LoyaOne environments.
> (b) This repository is a reference implementation of the LoyaOne design. Production
> was provisioned separately; this is the version I would build today.

[![terraform](https://github.com/keniiy/loyaone-infra-terraform/actions/workflows/terraform.yml/badge.svg)](https://github.com/keniiy/loyaone-infra-terraform/actions/workflows/terraform.yml)

## What you get

- **16 modules** under `modules/`, each with typed and documented inputs, outputs and a README
- **3 environments** (`dev`, `staging`, `prod`) that share one composition file; only `locals.tf` differs
- **Remote state** in S3 with DynamoDB locking, bootstrapped by `global/s3-backend`
- **Security by default**: private subnets, security groups by reference, KMS everywhere, TLS 1.3 at the edge, WAF in prod, Secrets Manager for credentials, no public IPs on compute
- **Operability**: Container Insights, encrypted ECS Exec, slow-query and flow logs, eleven alarm types wired to SNS, dead-letter queues with redrive
- **Delivery**: GitHub Actions runs `fmt`, `validate`, `tflint` (with the AWS ruleset) and `trivy` on every PR, then posts a plan per environment; deploys assume an OIDC role, no stored keys
- **Docs**: [architecture and decisions](docs/architecture.md), [runbook](docs/runbook.md)

## Layout

```
.
├── global/
│   ├── s3-backend/     state bucket + lock table (local state, applied once)
│   ├── kms/            one key per environment
│   └── ecr/            one repository per service
├── modules/
│   ├── vpc             ├── ecs-cluster      ├── rds            ├── sqs
│   ├── security-groups ├── ecs-service      ├── elasticache    ├── sns
│   ├── alb             ├── nats             ├── dynamodb       ├── s3
│   ├── waf             ├── iam              ├── ecr            └── cloudwatch
├── environments/
│   ├── dev/            main.tf (shared) + locals.tf (what makes it dev)
│   ├── staging/
│   └── prod/
├── docs/               architecture.md, runbook.md
└── .github/workflows/  terraform.yml
```

## Getting started

Prerequisites: Terraform >= 1.6, AWS CLI with credentials for the target account,
[tflint](https://github.com/terraform-linters/tflint) and
[trivy](https://github.com/aquasecurity/trivy) for `make lint`.

```bash
# 1. Once per account: state backend, KMS keys, ECR repositories
make bootstrap

# 2. Per environment
cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars
$EDITOR environments/dev/terraform.tfvars      # certificate ARN, OIDC provider ARN, services
make plan ENV=dev
make apply ENV=dev
```

`terraform.tfvars` is git-ignored. The values it needs are an ACM certificate ARN for
the ALB, the account's GitHub OIDC provider ARN, alarm email addresses, and the map of
services to run (image tag, port, routing rule, size).

## How a request flows

```
client -> (WAF, prod) -> ALB :443 -> listener rule (host or path) -> target group
       -> ECS task in a private subnet -> RDS / Redis / NATS / SQS / DynamoDB
       -> outbound to payment providers via the NAT gateway's fixed IP
```

Full diagram and the reasoning behind each choice: [docs/architecture.md](docs/architecture.md).

## Working on it

```bash
make fmt        # terraform fmt -recursive
make lint       # fmt check, tflint per stack, trivy config scan
make validate ENV=staging
pre-commit install   # runs fmt, validate, tflint, docs and trivy before every commit
```

Pull requests get a plan comment per environment from CI. Applies to `dev` and `staging`
run on merge to `main`; `prod` applies are manual and require the `prod` GitHub environment
approval.

## Conventions

- Every resource is tagged `Project`, `Environment`, `ManagedBy` via provider `default_tags`
- Names are `loyaone-<env>-<thing>`; log groups are `/loyaone/<env>/<thing>`
- Modules never create providers or backends; environments do
- A module's README is generated from its variables and outputs; edit the `.tf`, not the table
- Anything that differs between environments goes in `locals.tf`, nowhere else

## Licence

MIT. See [LICENSE](LICENSE).
