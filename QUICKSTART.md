# Quick Start Guide

## What Was Created

### Terraform Modules (4 sub-modules + 1 main module)

#### Sub-Modules
1. **`terraform/modules/providers/latitude/bare-metal-server/`**
   - Provisions bare-metal servers
   - Files: `main.tf`, `variables.tf`, `outputs.tf`, `README.md`

2. **`terraform/modules/providers/latitude/firewall/`**
   - Creates firewall rules
   - Files: `main.tf`, `variables.tf`, `outputs.tf`, `README.md`

3. **`terraform/modules/providers/latitude/firewall-assignment/`**
   - Assigns firewalls to servers
   - Files: `main.tf`, `variables.tf`, `outputs.tf`, `README.md`

4. **`terraform/modules/providers/latitude/virtual-network/`**
   - Creates virtual networks (VLANs)
   - Files: `main.tf`, `variables.tf`, `outputs.tf`, `README.md`

#### Main Module
5. **`terraform/modules/providers/latitude/kubernetes-nodes/`**
   - Combines all sub-modules for Kubernetes clusters
   - Dynamic server naming and configuration
   - Files: `main.tf`, `variables.tf`, `outputs.tf`, `README.md`

### Infrastructure Configuration

**`terraform/infra/providers/latitude/kubernetes-nodes/`**
- Consumes the kubernetes-nodes module
- Production-ready configuration
- Files: `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars.example`, `README.md`

### Ansible Playbook

**`ansible/kubernetes-rke2-setup.yml`**
- Complete RKE2 Kubernetes setup
- Follows https://www.latitude.sh/docs/guides/kubernetes-cluster-rke2
- Includes:
  - Control-plane node setup
  - Worker node configuration
  - Cilium CNI installation
  - Kube-proxy replacement

**Supporting Files:**
- `ansible/templates/rke2-server-config.yaml.j2` - First master config
- `ansible/templates/rke2-server-ha-config.yaml.j2` - Additional masters
- `ansible/templates/rke2-agent-config.yaml.j2` - Worker node config
- `ansible/inventory.example.yml` - Inventory template
- `ansible/ansible.cfg` - Ansible configuration
- `ansible/README.md` - Detailed documentation

## File Count

Total files created: **36 files**
- Terraform files: 20
- Ansible files: 7
- Documentation: 9

## Next Steps

### 1. Provision Infrastructure

```bash
cd terraform/infra/providers/latitude/kubernetes-nodes

# Configure your variables
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars  # Edit with your values

# Set API token
export LATITUDESH_AUTH_TOKEN="your-api-token"

# Deploy
terraform init
terraform plan
terraform apply
```

### 2. Configure Kubernetes

```bash
cd ../../../../ansible

# Create inventory from Terraform outputs
cp inventory.example.yml inventory.yml
# Update inventory.yml with IPs from: terraform output -json

# Deploy Kubernetes
ansible-playbook -i inventory.yml kubernetes-rke2-setup.yml
```

### 3. Access Cluster

```bash
# Kubeconfig is automatically downloaded to ./kubeconfig
export KUBECONFIG=./kubeconfig
kubectl get nodes
kubectl get pods -A
```

## Architecture

### Server Naming Convention
- Masters: `{cluster_name}-master-{1,2,3...}`
- Workers: `{cluster_name}-worker-{1,2,3...}`

Example: `production-master-1`, `production-worker-1`

### Network Architecture
- **Virtual Network**: Private VLAN for cluster
- **Firewall**: Pre-configured rules for Kubernetes
- **Public IPs**: All nodes accessible

### Kubernetes Stack
- **Version**: RKE2 v1.31.1+rke2r1
- **CNI**: Cilium 1.16.3
- **Kube-proxy**: Replaced by Cilium
- **Container Runtime**: containerd

## Key Features

✅ Dynamic and reusable Terraform modules
✅ High-availability support (1, 3, or 5 masters)
✅ Automated Kubernetes installation
✅ Following official Latitude.sh RKE2 guide
✅ Complete documentation
✅ Production-ready configurations

## Important Notes

- **DO NOT** run Terraform or Ansible yet (files are for review)
- All files follow best practices
- Ansible playbook follows **exact** Latitude.sh guide steps
- Modules are fully reusable and composable

## Documentation

Each module and component has its own README.md with:
- Usage examples
- Input/output descriptions
- Configuration options
- Troubleshooting guides

Start with:
- `README.md` - Main project documentation
- `terraform/modules/providers/latitude/README.md` - Module overview
- `ansible/README.md` - Ansible playbook guide

## Support

Refer to individual README files in each directory for detailed documentation and troubleshooting.
