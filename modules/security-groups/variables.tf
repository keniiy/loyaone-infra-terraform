variable "name" {
  description = "Name prefix, e.g. loyaone-dev."
  type        = string
}

variable "vpc_id" {
  description = "VPC the groups belong to."
  type        = string
}

variable "container_port_range" {
  description = "Port range the ALB may reach on ECS tasks."
  type = object({
    from = number
    to   = number
  })
  default = {
    from = 3000
    to   = 3999
  }
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
