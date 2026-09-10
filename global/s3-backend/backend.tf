// This stack is intentionally on local state. It creates the remote backend
// everything else uses, so it cannot depend on that backend existing.
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
