variable "name" {
  description = "Environment prefix, e.g. loyaone-prod."
  type        = string
}

variable "alb_arn" {
  description = "ALB to protect."
  type        = string
}

variable "rate_limit_per_5_minutes" {
  description = "Requests per IP per 5 minutes before blocking."
  type        = number
  default     = 2000
}

variable "managed_rule_groups" {
  description = "AWS managed rule groups to enable, in priority order."
  type        = list(string)
  default = [
    "AWSManagedRulesCommonRuleSet",
    "AWSManagedRulesKnownBadInputsRuleSet",
    "AWSManagedRulesAmazonIpReputationList",
  ]
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
