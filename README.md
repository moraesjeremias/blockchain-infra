# Blockchain Infrastructure

Infrastructure as Code for deploying Kubernetes clusters on Latitude.sh bare-metal servers using Terraform and Ansible.

## Project Structure

```
blockchain-infra/
├── terraform/
│   ├── modules/
│   │   └── providers/
│   │       └── latitude/
│   │           └── bare-metal-server/    # Reusable server provisioning module
│   └── infra/
│       └── providers/
│           └── latitude/
│               └── k8s-nodes/            # Production K8s cluster infrastructure
├── ansible/
│   ├── inventory/
│   │   └── hosts.yml                     # Inventory file (update with server IPs)
│   ├── group_vars/
│   │   └── all.yml                       # Global variables (tokens, versions)
│   ├── playbooks/
│   │   ├── 00-check-connectivity.yml     # Ping and verify all nodes
│   │   ├── 01-install-rke2-control-plane.yml
│   │   ├── 02-install-rke2-workers.yml
│   │   ├── 03-configure-cilium.yml       # Cilium with helmfile
│   │   ├── 04-check-cluster-status.yml   # Cluster health check
│   │   └── site.yml                      # Full deployment playbook
│   └── roles/
│       ├── rke2-common/                  # Shared RKE2 configuration
│       ├── rke2-server/                  # Control plane installation
│       ├── rke2-agent/                   # Worker node installation
│       └── cilium/                       # Cilium CNI with helmfile
└── values.yml                            # Cilium Helm values
```

## Prerequisites

- Terraform >= 1.13.5
- Ansible >= 2.12
- Latitude.sh account with API token
- Google Cloud account (for Secret Manager and Terraform state)
- SSH key uploaded to Latitude.sh

## Quick Start

### Step 1: Environment Setup

```bash
# Set Latitude.sh API token
export LATITUDESH_AUTH_TOKEN="your-api-token"

# Set Google Cloud credentials
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"
```

### Step 2: Provision Infrastructure with Terraform

```bash
cd terraform/infra/providers/latitude/k8s-nodes

# Initialize Terraform (uses GCS backend)
terraform init

# Review planned changes
terraform plan

# Apply infrastructure
terraform apply
```

This provisions:
- **2 Control Plane nodes** (`control-plane-1`, `control-plane-2`) - c2-small-x86
- **1 Worker node** (`worker-1`) - s2-small-x86
- All nodes run Ubuntu 24.04 LTS in NYC region

### Step 3: Configure Ansible Inventory

Update `ansible/inventory/hosts.yml` with the IPs from Terraform output:

```yaml
all:
  children:
    control_plane:
      hosts:
        control-plane-1:
          ansible_host: <CONTROL_PLANE_1_IP>
        control-plane-2:
          ansible_host: <CONTROL_PLANE_2_IP>
    workers:
      hosts:
        worker-1:
          ansible_host: <WORKER_1_IP>
```

### Step 4: Generate Tokens

Generate secure tokens for RKE2 cluster communication:

```bash
# Generate server token
openssl rand -hex 32

# Generate agent token
openssl rand -hex 32
```

Update `ansible/group_vars/all.yml`:

```yaml
rke2_token: "your-generated-server-token"
rke2_agent_token: "your-generated-agent-token"
```

### Step 5: Deploy Kubernetes with Ansible

```bash
cd ansible

# Option 1: Run full deployment
ansible-playbook playbooks/site.yml

# Option 2: Run step by step
ansible-playbook playbooks/00-check-connectivity.yml
ansible-playbook playbooks/01-install-rke2-control-plane.yml
ansible-playbook playbooks/02-install-rke2-workers.yml
ansible-playbook playbooks/03-configure-cilium.yml
ansible-playbook playbooks/04-check-cluster-status.yml
```

### Step 6: Access Your Cluster

```bash
# Kubeconfig is automatically fetched to ansible/kubeconfig
export KUBECONFIG=ansible/kubeconfig

# Verify cluster
kubectl get nodes
kubectl get pods -A
```

## Terraform Configuration

### Provider Versions

| Provider | Version |
|----------|---------|
| Terraform | >= 1.13.5 |
| latitudesh/latitudesh | ~> 2.8.3 |
| hashicorp/google | ~> 7.12.0 |

### Remote State

Terraform state is stored in GCS bucket `blokchain-terraform-states` with prefix `sandbox/latitude/servers`.

### Secrets Management

The Latitude.sh project ID is fetched from Google Secret Manager:
- Secret: `latitude_project_id`
- Project: `moraesjeremias-studies`

### Module Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `os` | string | - | Operating system (e.g., `ubuntu_24_04_x64_lts`) |
| `project` | string | - | Latitude.sh project ID |
| `ssh_key_slug` | string | - | SSH key slug in Latitude.sh |
| `instance_type` | string | `c2-small-x86` | Server instance type |
| `hostname` | string | `sandbox-machine` | Base hostname (suffixed with index) |
| `region` | string | `SAO2` | Deployment region |
| `node_count` | number | `1` | Number of servers to provision |
| `tags` | list(string) | - | Tags for the servers |

## Ansible Configuration

### Playbooks

| Playbook | Description |
|----------|-------------|
| `00-check-connectivity.yml` | Ping all nodes and display system info |
| `01-install-rke2-control-plane.yml` | Install RKE2 server on control plane (serial) |
| `02-install-rke2-workers.yml` | Install RKE2 agent on worker nodes |
| `03-configure-cilium.yml` | Deploy Cilium via helmfile |
| `04-check-cluster-status.yml` | Verify cluster health and components |
| `site.yml` | Run all playbooks in sequence |

### Key Variables (group_vars/all.yml)

| Variable | Default | Description |
|----------|---------|-------------|
| `rke2_version` | `v1.31.1+rke2r1` | RKE2 version to install |
| `rke2_channel` | `stable` | RKE2 release channel |
| `rke2_cni` | `cilium` | CNI plugin |
| `rke2_disable_kube_proxy` | `true` | Disable kube-proxy (Cilium replacement) |
| `helm_version` | `3.16.3` | Helm version |
| `helmfile_version` | `0.169.2` | Helmfile version |

### Cilium Configuration

Cilium is deployed with helmfile using the following configuration:

```yaml
hubble:
  enabled: true
  relay:
    enabled: true
  ui:
    enabled: true
kubeProxyReplacement: true
ipam:
  mode: kubernetes
```

## Architecture

### Network Topology

```
┌─────────────────────────────────────────────────────────────┐
│                      Latitude.sh NYC                         │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐                   │
│  │ control-plane-1 │  │ control-plane-2 │   Control Plane   │
│  │   c2-small-x86  │  │   c2-small-x86  │                   │
│  │   RKE2 Server   │  │   RKE2 Server   │                   │
│  └────────┬────────┘  └────────┬────────┘                   │
│           │                    │                             │
│           └────────┬───────────┘                             │
│                    │ Port 9345 (RKE2 Supervisor)             │
│                    │ Port 6443 (K8s API)                     │
│           ┌────────┴────────┐                                │
│           │    worker-1     │           Workers              │
│           │  s2-small-x86   │                                │
│           │   RKE2 Agent    │                                │
│           └─────────────────┘                                │
└─────────────────────────────────────────────────────────────┘
```

### Kubernetes Components

- **Container Runtime**: containerd (via RKE2)
- **CNI**: Cilium with kube-proxy replacement
- **Observability**: Hubble (UI + Relay)
- **Ingress**: Disabled (rke2-ingress-nginx disabled)

### Ports

| Port | Protocol | Service |
|------|----------|---------|
| 22 | TCP | SSH |
| 6443 | TCP | Kubernetes API |
| 9345 | TCP | RKE2 Supervisor |
| 2379-2380 | TCP | etcd |
| 10250 | TCP | Kubelet |
| 4240 | TCP | Cilium Health |
| 8472 | UDP | Cilium VXLAN |

## Operations

### Check Cluster Status

```bash
cd ansible
ansible-playbook playbooks/04-check-cluster-status.yml
```

This verifies:
- All nodes are Ready
- Cilium pods are running
- kube-proxy is disabled
- Hubble components are healthy

### Scale Workers

1. Update `terraform/infra/providers/latitude/k8s-nodes/main.tf`:
   ```hcl
   module "k8s-worker" {
     node_count = 3  # Increase from 1
   }
   ```

2. Apply changes:
   ```bash
   cd terraform/infra/providers/latitude/k8s-nodes
   terraform apply
   ```

3. Update Ansible inventory and run:
   ```bash
   cd ansible
   ansible-playbook playbooks/02-install-rke2-workers.yml
   ```

### View Logs

```bash
# On control plane nodes
journalctl -u rke2-server -f

# On worker nodes
journalctl -u rke2-agent -f
```

### Reset a Node

```bash
# On control plane
/usr/local/bin/rke2-uninstall.sh

# On worker
/usr/local/bin/rke2-agent-uninstall.sh
```

## Troubleshooting

### Terraform

```bash
# Validate configuration
terraform validate

# Check state
terraform show

# Force unlock (if state is locked)
terraform force-unlock <lock-id>
```

### Ansible

```bash
# Test connectivity
ansible all -m ping

# Verbose output
ansible-playbook playbooks/site.yml -vvv

# Limit to specific hosts
ansible-playbook playbooks/02-install-rke2-workers.yml --limit worker-1
```

### Kubernetes

```bash
# Check nodes
kubectl get nodes -o wide

# Check system pods
kubectl get pods -n kube-system

# Describe problematic pod
kubectl describe pod -n kube-system <pod-name>

# Cilium status
kubectl exec -n kube-system ds/cilium -- cilium status
```

## Clean Up

```bash
# Destroy all infrastructure
cd terraform/infra/providers/latitude/k8s-nodes
terraform destroy
```

## References

- [Latitude.sh RKE2 Guide](https://www.latitude.sh/docs/guides/kubernetes-cluster-rke2)
- [RKE2 Documentation](https://docs.rke2.io/)
- [Cilium Documentation](https://docs.cilium.io/)
- [Helmfile Documentation](https://helmfile.readthedocs.io/)
