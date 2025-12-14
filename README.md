# Loyaone Infrastructure Terraform

This repository contains Terraform configurations for managing the Loyaone infrastructure on AWS. It follows infrastructure-as-code best practices with a modular structure supporting multiple environments.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [State Management](#state-management)
- [Environments](#environments)
- [Modules](#modules)
- [Usage Examples](#usage-examples)
- [Best Practices](#best-practices)
- [Security](#security)
- [Contributing](#contributing)

## Prerequisites

Before you begin, ensure you have the following installed:

- **Terraform** >= 1.0.0 ([Installation Guide](https://www.terraform.io/downloads))
- **AWS CLI** configured with appropriate credentials ([Setup Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html))
- **Git** for version control
- AWS account with appropriate IAM permissions

### AWS Credentials Setup

Configure your AWS credentials using one of these methods:

```bash
# Option 1: AWS CLI configuration
aws configure

# Option 2: Environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="eu-west-2"

# Option 3: AWS SSO (recommended for teams)
aws sso login --profile your-profile
```

## Project Structure

```text
loyaone-infra-terraform/
├── README.md
├── .gitignore
├── environments/          # Environment-specific configurations
│   ├── dev/              # Development environment
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── providers.tf
│   │   └── variables.tf
│   ├── staging/          # Staging environment
│   └── prod/             # Production environment
├── global/               # Global/shared resources
│   ├── kms/             # KMS key management
│   └── s3-backend/      # S3 backend for Terraform state
│       ├── backend.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       └── variables.tf
└── modules/              # Reusable Terraform modules
    ├── cloudwatch/      # CloudWatch monitoring
    ├── dynamodb/        # DynamoDB tables
    ├── ec2/             # EC2 instances
    ├── eks/             # EKS clusters
    ├── iam/             # IAM roles and policies
    ├── rds/             # RDS databases
    ├── sns/             # SNS topics
    ├── sqs/             # SQS queues
    └── vpc/             # VPC networking
        ├── main.tf
        ├── outputs.tf
        └── variables.tf
```

## Getting Started

### 1. Initialize the Global Backend (First Time Only)

The S3 backend must be created before other environments can use it:

```bash
cd global/s3-backend
terraform init
terraform plan
terraform apply
```

This creates:

- S3 bucket: `loyaone-terraform-state` (for storing Terraform state)
- DynamoDB table: `loyaone-terraform-locks` (for state locking)

### 2. Set Up an Environment

Navigate to your desired environment:

```bash
cd environments/dev
```

Initialize Terraform:

```bash
terraform init
```

Review the planned changes:

```bash
terraform plan
```

Apply the configuration:

```bash
terraform apply
```

## State Management

This project uses **remote state** stored in S3 with DynamoDB locking:

- **State Location**: `s3://loyaone-terraform-state/envs/{environment}/terraform.tfstate`
- **Lock Table**: `loyaone-terraform-locks`
- **Region**: `eu-west-2`
- **Encryption**: Enabled (AES256)

### State Backend Configuration

Each environment's `backend.tf` is pre-configured:

```hcl
terraform {
  backend "s3" {
    bucket         = "loyaone-terraform-state"
    key            = "envs/dev/terraform.tfstate"
    region         = "eu-west-2"
    use_lockfile   = true
    encrypt        = true
    dynamodb_table = "loyaone-terraform-locks"
  }
}
```

## Environments

### Development (`environments/dev/`)

Development environment with relaxed security for testing.

**Features:**

- VPC with public and private subnets
- NAT Gateway enabled for outbound internet access
- Cost-optimized resources

### Staging (`environments/staging/`)

Staging environment mirroring production for pre-release testing.

### Production (`environments/prod/`)

Production environment with enhanced security and monitoring.

## Modules

### VPC Module

Creates a VPC with public and private subnets, internet gateway, and NAT gateway.

**Usage:**

```hcl
module "vpc" {
  source = "../../modules/vpc"

  name     = "loyaone-dev"
  vpc_cidr = "10.0.0.0/16"

  azs = [
    "eu-west-2a",
    "eu-west-2b",
  ]

  public_subnets_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24",
  ]

  private_subnets_cidrs = [
    "10.0.11.0/24",
    "10.0.12.0/24",
  ]

  enable_nat_gateway = true

  tags = {
    Project     = "LoyaOne"
    Environment = "dev"
  }
}
```

**Outputs:**

- `vpc_id` - VPC ID
- `public_subnet_ids` - List of public subnet IDs
- `private_subnet_ids` - List of private subnet IDs
- `public_route_table_id` - Public route table ID
- `private_route_table_id` - Private route table ID

### Other Modules

- **CloudWatch**: Monitoring and logging
- **DynamoDB**: NoSQL database tables
- **EC2**: Compute instances
- **EKS**: Kubernetes clusters
- **IAM**: Roles and policies
- **RDS**: Relational databases
- **SNS**: Notification topics
- **SQS**: Message queues

## Usage Examples

### Creating Infrastructure in Dev Environment

```bash
# Navigate to dev environment
cd environments/dev

# Initialize (if first time)
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# View outputs
terraform output
```

### Destroying Infrastructure

```bash
# Review what will be destroyed
terraform plan -destroy

# Destroy infrastructure
terraform destroy
```

### Working with Modules

To use a module in an environment:

1. Add the module block to `main.tf`
2. Reference the module source: `source = "../../modules/{module-name}"`
3. Provide required variables
4. Run `terraform init` to download the module
5. Run `terraform plan` and `terraform apply`

## Best Practices

1. **Always run `terraform plan` before `terraform apply`**
   - Review changes carefully, especially in production

2. **Use workspaces for multiple environments** (optional)

   ```bash
   terraform workspace new staging
   terraform workspace select staging
   ```

3. **Keep state files secure**
   - Never commit `.tfstate` files
   - Use remote state (already configured)
   - Enable encryption (already enabled)

4. **Version control**
   - Commit all `.tf` files
   - Use meaningful commit messages
   - Review changes via pull requests

5. **Tag resources**
   - All resources should have appropriate tags
   - Include: Project, Environment, Owner, etc.

6. **Modularize code**
   - Use modules for reusable components
   - Keep modules in `modules/` directory

7. **Documentation**
   - Document complex configurations
   - Add descriptions to variables and outputs

## Security

### Credentials Management

- **Never commit secrets** to version control
- Use AWS IAM roles when possible (EC2, Lambda, etc.)
- Use AWS Secrets Manager or Parameter Store for sensitive data
- Rotate credentials regularly

### State File Security

- State files are stored in encrypted S3 bucket
- Access is restricted via IAM policies
- State locking prevents concurrent modifications

### Network Security

- Use private subnets for sensitive resources
- Implement security groups with least privilege
- Enable VPC Flow Logs for monitoring

## Contributing

1. **Create a feature branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow existing code style
   - Add comments for complex logic
   - Update documentation as needed

3. **Test your changes**

   ```bash
   terraform init
   terraform validate
   terraform plan
   ```

4. **Commit and push**

   ```bash
   git add .
   git commit -m "Description of changes"
   git push origin feature/your-feature-name
   ```

5. **Create a Pull Request**
   - Provide clear description
   - Reference related issues
   - Request review from team members

## Troubleshooting

### Common Issues

**Issue**: `Error: Failed to get existing workspaces`

- **Solution**: Ensure S3 backend is initialized first (see [Getting Started](#getting-started))

**Issue**: `Error: Error acquiring the state lock`

- **Solution**: Another process is using the state. Wait or check for stale locks in DynamoDB

**Issue**: `Error: Invalid AWS credentials`

- **Solution**: Verify AWS credentials are configured correctly (see [Prerequisites](#prerequisites))

### Getting Help

- Check [Terraform documentation](https://www.terraform.io/docs)
- Review [AWS provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- Contact the infrastructure team

## License

[Add your license here]

## Contact

**Project Owner**: Kehinde
**Repository**: [https://github.com/keniiy/loyaone-infra-terraform](https://github.com/keniiy/loyaone-infra-terraform)

---

**⚠️ Remember**: Always review `terraform plan` output before applying changes, especially in production environments!
