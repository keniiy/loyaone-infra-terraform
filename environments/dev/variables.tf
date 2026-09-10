variable "region" {
  description = "AWS region."
  type        = string
  default     = "eu-west-2"
}

variable "certificate_arn" {
  description = "ACM certificate ARN (same region) for the ALB HTTPS listener."
  type        = string
}

variable "alarm_emails" {
  description = "Addresses subscribed to the alarms topic."
  type        = list(string)
  default     = []
}

variable "github_repository" {
  description = "owner/repo whose GitHub Actions may deploy to this environment."
  type        = string
  default     = "keniiy/loyaone-backend"
}

variable "github_oidc_provider_arn" {
  description = "ARN of the account's GitHub OIDC provider (created once, outside this stack)."
  type        = string
}

variable "services" {
  description = "Services to run. Key is the service name and must match an ECR repository."
  type = map(object({
    image_tag     = string
    port          = optional(number, 3000)
    cpu           = optional(number, 512)
    memory        = optional(number, 1024)
    min_count     = optional(number, 1)
    max_count     = optional(number, 4)
    expose        = optional(bool, true)
    priority      = optional(number, 100)
    host_headers  = optional(list(string), [])
    path_patterns = optional(list(string), [])
    environment   = optional(map(string), {})
    secrets       = optional(map(string), {})
  }))
}
