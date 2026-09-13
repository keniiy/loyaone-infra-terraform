output "deploy_role_arn" {
  description = "Role ARN for the GitHub Actions workflow to assume."
  value       = aws_iam_role.deploy.arn
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN in use."
  value       = local.oidc_provider_arn
}
