# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Infrastructure as Code for deploying Kubernetes clusters on Latitude.sh bare-metal servers. Uses Terraform for provisioning, Ansible for configuration management, and stores secrets in Google Cloud Secret Manager and Ansible Vault.

## Commands

### Terraform

```bash
# Navigate to infra directory
cd terraform/infra/providers/latitude/k8s-nodes

# Initialize (uses GCS backend for state)
terraform init

# Format all Terraform files
terraform fmt -recursive

# Validate configuration
terraform validate

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy
```

### Pre-commit Hooks

```bash
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install

# Run all hooks manually
pre-commit run --all-files
```

### Linting

```bash
# YAML linting
yamllint .

# Terraform linting (via pre-commit or directly)
tflint
```

### Ansible

```bash
# Navigate to ansible directory
cd ansible

# Test connectivity to all hosts
ansible all -m ping

# Run full cluster deployment
ansible-playbook playbooks/site.yml

# Run individual playbooks
ansible-playbook playbooks/00-check-connectivity.yml
ansible-playbook playbooks/01-update-packages.yml
ansible-playbook playbooks/02-install-rke2-control-plane.yml
ansible-playbook playbooks/03-install-rke2-workers.yml
ansible-playbook playbooks/04-configure-cilium.yml
ansible-playbook playbooks/05-check-cluster-status.yml

# Encrypt vault file
ansible-vault encrypt inventory/group_vars/all/vault.yml

# Edit encrypted vault
ansible-vault edit inventory/group_vars/all/vault.yml

# Run with explicit vault password (if .vault_password not configured)
ansible-playbook playbooks/site.yml --vault-password-file=.vault_password
```

## Architecture

### Terraform Structure

- **`terraform/modules/providers/latitude/`** - Reusable modules for Latitude.sh resources
  - `bare-metal-server/` - Provisions servers with dynamic hostname naming (`{hostname}-{index}`)
- **`terraform/infra/providers/latitude/k8s-nodes/`** - Production infrastructure consuming the modules

### Ansible Structure

- **`ansible/inventory/`** - Inventory and group variables
  - `hosts.yml` - Host definitions (IPs stored in vault)
  - `group_vars/all/vars.yml` - Non-sensitive configuration
  - `group_vars/all/vault.yml` - Encrypted secrets (tokens, IPs)
- **`ansible/playbooks/`** - Deployment playbooks (numbered for execution order)
- **`ansible/roles/`** - Reusable roles
  - `rke2-common/` - Shared RKE2 configuration and templates
  - `rke2-server/` - Control plane installation
  - `rke2-agent/` - Worker node installation
  - `cilium/` - Cilium CNI with helmfile

### Key Patterns

- **Remote State**: Terraform state stored in GCS bucket `blokchain-terraform-states`
- **Secrets (Terraform)**: Latitude.sh project ID fetched from Google Secret Manager (`latitude_project_id` in project `moraesjeremias-studies`)
- **Secrets (Ansible)**: RKE2 tokens and host IPs stored in Ansible Vault (`inventory/group_vars/all/vault.yml`)
- **Authentication**: Latitude.sh API token via `LATITUDESH_AUTH_TOKEN` environment variable
- **Server Naming**: Servers named as `{hostname}-{count.index + 1}` (e.g., `control-plane-1`, `worker-1`)
- **SSH Access**: User `ubuntu` with key `~/.ssh/latitude_ssh_key` and `-o IdentitiesOnly=yes`

### Provider Versions

- Terraform >= 1.13.5
- latitudesh/latitudesh ~> 2.8.3
- hashicorp/google ~> 7.12.0

### Ansible Versions

- RKE2: v1.35.0+rke2r1
- Helm: 3.19.0
- Helmfile: 1.2.3
- Cilium: 1.16.5 (deployed via helmfile)

## Pre-commit Configuration

The repository uses pre-commit hooks for:
- `terraform_fmt` - Format Terraform files
- `terraform_tflint` - Lint with rules for required versions, unused declarations, deprecated syntax
- `terraform_docs` - Auto-generate module documentation in README.md files
- `yamllint` / `yamlfmt` - YAML formatting (excludes templates and helmfile)
- Standard hooks: trailing whitespace, private key detection, merge conflict checks

## Environment Setup

```bash
# Terraform
export LATITUDESH_AUTH_TOKEN="your-api-token"
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"

# Ansible vault password (create this file, add to .gitignore)
echo "your-vault-password" > ansible/.vault_password
chmod 600 ansible/.vault_password
```

## Kubernetes Cluster Details

- **CNI**: Cilium with kube-proxy replacement (`kubeProxyReplacement: true`)
- **Observability**: Hubble enabled (UI + Relay)
- **Ingress**: Disabled (rke2-ingress-nginx disabled by default)
- **Control Plane**: 2 nodes (HA with embedded etcd)
- **Workers**: 1 node (scalable via Terraform `node_count`)
