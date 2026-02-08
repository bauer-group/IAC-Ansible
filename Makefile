# IAC-Ansible Makefile
# Usage: make <target> [LIMIT=<pattern>] [TAGS=<tags>] [ENV=<environment>]

SHELL := /bin/bash
ENV ?= production
INVENTORY := inventory/$(ENV)/hosts.yml
LIMIT_ARG := $(if $(LIMIT),--limit "$(LIMIT)",)
TAGS_ARG := $(if $(TAGS),--tags "$(TAGS)",)
LABEL_ARG := $(if $(LABEL),-e "filter_label=$(LABEL)",)
SERVICE_ARG := $(if $(SERVICE),-e "filter_service=$(SERVICE)",)
EXTRA_ARGS := $(LIMIT_ARG) $(TAGS_ARG) $(LABEL_ARG) $(SERVICE_ARG)

.PHONY: help setup deploy update reboot ping facts lint check push cleanup vault-edit vault-create

help: ## Show this help
	@echo "IAC-Ansible - Infrastructure as Code"
	@echo ""
	@echo "Usage: make <target> [OPTIONS]"
	@echo ""
	@echo "Options:"
	@echo "  LIMIT=<pattern>    Filter hosts (supports wildcards: *.bauer-group.com)"
	@echo "  TAGS=<tags>        Run only specific tags"
	@echo "  LABEL=<label>      Filter by host label"
	@echo "  SERVICE=<service>  Filter by running service"
	@echo "  ENV=<env>          Environment (default: production)"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Examples:"
	@echo "  make deploy                                    # Deploy to all servers"
	@echo "  make deploy LIMIT=0046-20.cloud.bauer-group.com"
	@echo "  make deploy LIMIT='*.bauer-group.com'"
	@echo "  make update LIMIT='192.168.1.*'"
	@echo "  make deploy LABEL=webserver"
	@echo "  make deploy SERVICE=nginx"
	@echo "  make check                                     # Dry-run mode"

setup: ## Initial setup - install requirements
	ansible-galaxy install -r requirements.yml --force
	@echo "Setup complete."

deploy: ## Run full deployment (site.yml)
	ansible-playbook -i $(INVENTORY) playbooks/site.yml $(EXTRA_ARGS)

update: ## Run system updates only
	ansible-playbook -i $(INVENTORY) playbooks/update.yml $(EXTRA_ARGS)

reboot: ## Controlled reboot
	ansible-playbook -i $(INVENTORY) playbooks/maintenance/reboot.yml $(EXTRA_ARGS)

cleanup: ## Run cleanup tasks
	ansible-playbook -i $(INVENTORY) playbooks/maintenance/cleanup.yml $(EXTRA_ARGS)

ping: ## Ping all hosts
	ansible -i $(INVENTORY) all -m ping $(LIMIT_ARG)

facts: ## Gather and display facts
	ansible -i $(INVENTORY) all -m setup $(LIMIT_ARG)

lint: ## Lint all playbooks and roles
	ansible-lint playbooks/ roles/
	yamllint .

check: ## Dry-run deployment (check mode)
	ansible-playbook -i $(INVENTORY) playbooks/site.yml $(EXTRA_ARGS) --check --diff

push: ## Trigger immediate update on remote hosts via SSH
	@if [ -z "$(LIMIT)" ]; then \
		echo "ERROR: LIMIT required for push. Usage: make push LIMIT=<host>"; \
		exit 1; \
	fi
	ansible -i $(INVENTORY) "$(LIMIT)" -m ansible.builtin.systemd -a "name=ansible-pull.service state=started" --become $(LABEL_ARG)

vault-edit: ## Edit vault secrets
	ansible-vault edit inventory/$(ENV)/group_vars/all/secrets.yml

vault-create: ## Create new vault file
	ansible-vault create inventory/$(ENV)/group_vars/all/secrets.yml
