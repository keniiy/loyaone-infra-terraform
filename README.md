# Loyaone Infrastructure Terraform

## Project Structure

```text
loyaone-infra-terraform/
├── README.md
├── environments/
│   ├── dev/
│   ├── prod/
│   └── staging/
├── global/
│   ├── kms/
│   └── s3-backend/
│       ├── backend.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       └── variables.tf
└── modules/
    ├── cloudwatch/
    ├── dynamodb/
    ├── ec2/
    ├── eks/
    ├── iam/
    ├── rds/
    ├── sns/
    ├── sqs/
    └── vpc/
```

## Directory Overview

- **environments/** - Environment-specific configurations (dev, prod, staging)
- **global/** - Global/shared resources
  - `kms/` - KMS key management
  - `s3-backend/` - S3 backend configuration for Terraform state
- **modules/** - Reusable Terraform modules for AWS services
