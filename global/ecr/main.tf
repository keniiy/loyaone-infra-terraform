// Container registries are account-level, not per environment: the same image
// digest is promoted dev -> staging -> prod, so they live in the global tree.

module "ecr" {
  source = "../../modules/ecr"

  namespace    = "loyaone"
  repositories = var.services
  tags         = var.tags
}
