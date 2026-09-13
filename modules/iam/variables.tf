variable "name" {
  description = "Environment prefix, e.g. loyaone-dev."
  type        = string
}

variable "github_repository" {
  description = "owner/repo allowed to assume the deploy role, e.g. keniiy/loyaone-backend."
  type        = string
}

variable "github_subjects" {
  description = "OIDC subject suffixes allowed, e.g. [\"ref:refs/heads/main\", \"environment:prod\"]."
  type        = list(string)
  default     = ["ref:refs/heads/main"]
}

variable "create_oidc_provider" {
  description = "Create the GitHub OIDC provider. Only one may exist per account; set false and pass oidc_provider_arn if it already exists."
  type        = bool
  default     = false
}

variable "oidc_provider_arn" {
  description = "Existing GitHub OIDC provider ARN when create_oidc_provider is false."
  type        = string
  default     = null
}

variable "ecr_repository_arns" {
  description = "ECR repository ARNs the role may push to."
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
