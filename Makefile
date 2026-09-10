# Usage: make plan ENV=dev  |  make apply ENV=prod  |  make lint
ENV ?= dev
DIR := environments/$(ENV)

.PHONY: fmt lint validate plan apply destroy docs bootstrap

fmt:
	terraform fmt -recursive

lint:
	terraform fmt -check -recursive
	@for d in global/s3-backend global/kms global/ecr environments/dev environments/staging environments/prod; do \
	  echo "== $$d"; tflint --chdir=$$d --config=$(CURDIR)/.tflint.hcl --format=compact || exit 1; \
	done
	trivy config --severity HIGH,CRITICAL --exit-code 1 .

validate:
	cd $(DIR) && terraform init -backend=false -input=false >/dev/null && terraform validate

plan:
	cd $(DIR) && terraform init -input=false && terraform plan -input=false -out=tfplan

apply:
	cd $(DIR) && terraform apply -input=false tfplan

destroy:
	@test "$(ENV)" != "prod" || (echo "refusing to destroy prod from make" && exit 1)
	cd $(DIR) && terraform init -input=false && terraform destroy

docs:
	@for d in modules/*; do terraform-docs markdown table --output-file README.md --output-mode inject $$d; done

# One-time, by hand, with local state. Creates the remote backend everything else uses.
bootstrap:
	cd global/s3-backend && terraform init && terraform apply
	cd global/kms && terraform init && terraform apply
	cd global/ecr && terraform init && terraform apply
