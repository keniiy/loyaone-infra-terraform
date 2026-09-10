output "alb_dns_name" {
  description = "Point your DNS records here."
  value       = module.alb.alb_dns_name
}

output "nat_gateway_ip" {
  description = "Egress IP to allow-list with payment providers."
  value       = module.vpc.nat_gateway_public_ip
}

output "nats_url" {
  description = "Internal NATS URL."
  value       = module.nats.nats_url
}

output "rds_endpoint" {
  description = "PostgreSQL endpoint."
  value       = module.rds.endpoint
}

output "redis_endpoint" {
  description = "Redis primary endpoint."
  value       = module.redis.primary_endpoint_address
}

output "deploy_role_arn" {
  description = "Role for GitHub Actions to assume when deploying to this environment."
  value       = module.deploy_role.deploy_role_arn
}

output "service_hostnames" {
  description = "Internal discovery hostnames per service."
  value       = { for k, s in module.services : k => s.discovery_hostname }
}
