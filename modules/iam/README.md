# iam

GitHub Actions deploy role via OIDC, scoped to one repository and branch or environment. Push to ECR and roll ECS services, nothing else.

## Usage

```hcl
module "iam" {
  source = "../../modules/iam"
  name = ...
  github_repository = ...
  ecr_repository_arns = ...
}
```

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `name` | Environment prefix, e.g. loyaone-dev. | `string` | required |
| `github_repository` | owner/repo allowed to assume the deploy role, e.g. keniiy/loyaone-backend. | `string` | required |
| `github_subjects` | OIDC subject suffixes allowed, e.g. [\"ref:refs/heads/main\", \"environment:prod\"]. | `list(string)` | `["ref:refs/heads/main"]` |
| `create_oidc_provider` | Create the GitHub OIDC provider. Only one may exist per account; set false and pass oidc_provider_arn if it already exists. | `bool` | `false` |
| `oidc_provider_arn` | Existing GitHub OIDC provider ARN when create_oidc_provider is false. | `string` | `null` |
| `ecr_repository_arns` | ECR repository ARNs the role may push to. | `list(string)` | required |
| `tags` | Tags applied to every resource. | `map(string)` | `{}` |

## Outputs

| Name | Description |
|---|---|
| `deploy_role_arn` | Role ARN for the GitHub Actions workflow to assume. |
| `oidc_provider_arn` | OIDC provider ARN in use. |
