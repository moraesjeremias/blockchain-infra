# Blockchain Infrastructure

Infrastructure as Code for deploying and managing blockchain-related Kubernetes clusters on Latitude.sh bare-metal servers.

## Project Structure

```
blockchain-infra/
├── terraform/
│   ├── modules/
│   │   └── providers/
│   │       └── latitude/
│   │           ├── bare-metal-server/      # Server provisioning module
│   │           ├── firewall/               # Firewall module
│   │           ├── firewall-assignment/    # Firewall assignment module
│   │           ├── virtual-network/        # VLAN module
│   │           └── kubernetes-nodes/       # Main K8s infrastructure module
│   └── infra/
│       └── providers/
│           └── latitude/
│               └── kubernetes-nodes/       # Production K8s cluster config
└── ansible/
    ├── kubernetes-rke2-setup.yml          # Main RKE2 installation playbook
    ├── templates/                          # Jinja2 templates
    ├── inventory.example.yml              # Example inventory
    └── ansible.cfg                         # Ansible configuration
```

## Components

### 1. Terraform Modules

Reusable modules for provisioning infrastructure on Latitude.sh:

- **bare-metal-server**: Provisions individual servers
- **firewall**: Creates and manages firewall rules
- **firewall-assignment**: Links firewalls to servers
- **virtual-network**: Creates private VLANs
- **kubernetes-nodes**: Main module that combines all sub-modules

### 2. Ansible Playbooks

Automated configuration management for Kubernetes:

- **kubernetes-rke2-setup.yml**: Complete RKE2 cluster setup following [Latitude.sh RKE2 guide](https://www.latitude.sh/docs/guides/kubernetes-cluster-rke2)

## Quick Start

### Prerequisites

- Terraform >= 1.5.0
- Ansible >= 2.12
- Latitude.sh account with API access
- SSH keys uploaded to Latitude.sh

### Step 1: Provision Infrastructure with Terraform

```bash
# Navigate to infrastructure directory
cd terraform/infra/providers/latitude/kubernetes-nodes

# Copy and configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your configuration

# Set Latitude.sh API token
export LATITUDESH_AUTH_TOKEN="your-api-token"

# Initialize and apply
terraform init
terraform plan
terraform apply
```

### Step 2: Configure Kubernetes with Ansible

```bash
# Navigate to ansible directory
cd ../../../../ansible

# Create inventory from Terraform outputs
cp inventory.example.yml inventory.yml
# Update inventory.yml with IPs from: terraform output -json

# Run playbook
ansible-playbook -i inventory.yml kubernetes-rke2-setup.yml
```

### Step 3: Access Your Cluster

```bash
# Use the downloaded kubeconfig
export KUBECONFIG=./kubeconfig
kubectl get nodes
kubectl get pods -A
```

## Infrastructure Architecture

### Network Architecture

- **Virtual Network**: Private VLAN for internal cluster communication
- **Firewall**: Pre-configured rules for Kubernetes components
- **Public IPs**: All nodes have public IPs for management

### Kubernetes Architecture

- **Control Plane**: 1-5 master nodes (HA configuration)
- **Workers**: Scalable worker nodes
- **CNI**: Cilium with kube-proxy replacement
- **Container Runtime**: containerd (via RKE2)

### Ports and Services

| Port | Protocol | Service | Description |
|------|----------|---------|-------------|
| 22 | TCP | SSH | Server management |
| 6443 | TCP | K8s API | Kubernetes API server |
| 9345 | TCP | RKE2 | Supervisor API |
| 2379-2380 | TCP | etcd | Cluster state |
| 10250 | TCP | Kubelet | Node management |
| 30000-32767 | TCP | NodePort | Service exposure |
| 4240 | TCP | Cilium | Health checks |
| 8472 | UDP | Cilium | VXLAN overlay |

## Configuration

### Terraform Variables

Key variables in `terraform.tfvars`:

```hcl
cluster_name = "production"
project      = "your-project-id"
site         = "SAO"
ssh_keys     = ["your-ssh-key-id"]

master_nodes = [
  { plan = "c2-small-x86" },
  { plan = "c2-small-x86" },
  { plan = "c2-small-x86" }
]

worker_nodes = [
  { plan = "c2-medium-x86" },
  { plan = "c2-medium-x86" }
]
```

### Ansible Configuration

Inventory structure in `inventory.yml`:

```yaml
all:
  children:
    k8s_masters:
      hosts:
        master-1:
          ansible_host: 192.168.1.10
    k8s_workers:
      hosts:
        worker-1:
          ansible_host: 192.168.1.20
```

## Features

### High Availability

- Support for 1, 3, or 5 master nodes
- etcd clustering
- Load-balanced API access

### Security

- Firewall rules for all components
- Private VLAN networking
- SSH key-based authentication
- TLS for all communications

### Scalability

- Easy worker node addition
- Dynamic node naming
- Automated configuration

### Monitoring & Observability

- Cilium network observability
- etcd metrics exposed
- Ready for Prometheus integration

## Customization

### Adding More Worker Nodes

Edit `terraform.tfvars`:

```hcl
worker_nodes = [
  { plan = "c2-medium-x86" },
  { plan = "c2-medium-x86" },
  { plan = "c2-medium-x86" },  # Add more entries
]
```

Then:

```bash
terraform apply
ansible-playbook -i inventory.yml kubernetes-rke2-setup.yml --limit k8s_workers
```

### Custom Firewall Rules

Override default rules in `terraform.tfvars`:

```hcl
custom_firewall_rules = [
  {
    protocol = "tcp"
    port     = "8080"
    sources  = ["0.0.0.0/0"]
  }
]
```

### Different Operating Systems

Specify OS in node configuration:

```hcl
master_nodes = [
  {
    plan             = "c2-small-x86"
    operating_system = "ubuntu_22_04_x64_lts"
  }
]
```

## Maintenance

### Updating Nodes

```bash
# SSH to nodes
ssh root@node-ip

# Update packages
apt update && apt upgrade -y

# Restart services if needed
systemctl restart rke2-server  # or rke2-agent
```

### Backup etcd

```bash
# On master node
/var/lib/rancher/rke2/bin/etcdctl snapshot save backup.db
```

### Scale Workers

Add nodes via Terraform, then run Ansible on new nodes only:

```bash
ansible-playbook -i inventory.yml kubernetes-rke2-setup.yml --limit new-worker
```

## Troubleshooting

### Terraform Issues

```bash
# Check provider version
terraform version

# Validate configuration
terraform validate

# Show current state
terraform show
```

### Ansible Issues

```bash
# Test connectivity
ansible -i inventory.yml all -m ping

# Check variables
ansible-inventory -i inventory.yml --list
```

### Kubernetes Issues

```bash
# Check node status
kubectl get nodes -o wide

# Check system pods
kubectl get pods -n kube-system

# View logs
kubectl logs -n kube-system <pod-name>
```

### RKE2 Issues

On master nodes:

```bash
journalctl -u rke2-server -f
systemctl status rke2-server
```

On worker nodes:

```bash
journalctl -u rke2-agent -f
systemctl status rke2-agent
```

## Clean Up

### Destroy Infrastructure

```bash
cd terraform/infra/providers/latitude/kubernetes-nodes
terraform destroy
```

### Reset Nodes Manually

If Terraform destroy fails:

```bash
# On each node
/usr/local/bin/rke2-uninstall.sh        # Masters
/usr/local/bin/rke2-agent-uninstall.sh  # Workers
```

## Best Practices

1. **Version Control**: Keep `terraform.tfvars` out of git (use `.gitignore`)
2. **State Management**: Use remote state (S3, GCS, etc.) for production
3. **Tagging**: Use meaningful tags for resource organization
4. **Backups**: Regular etcd backups for disaster recovery
5. **Monitoring**: Set up monitoring (Prometheus, Grafana)
6. **Updates**: Keep RKE2 and modules up to date
7. **Testing**: Test changes in staging before production

## References

- [Latitude.sh Documentation](https://www.latitude.sh/docs)
- [Latitude.sh RKE2 Guide](https://www.latitude.sh/docs/guides/kubernetes-cluster-rke2)
- [RKE2 Documentation](https://docs.rke2.io/)
- [Cilium Documentation](https://docs.cilium.io/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Ansible Documentation](https://docs.ansible.com/)

## Support

For issues:
- Terraform modules: Check module READMEs
- Ansible playbooks: Check ansible/README.md
- Latitude.sh: [Support Portal](https://www.latitude.sh/support)
- RKE2: [GitHub Issues](https://github.com/rancher/rke2/issues)

## License

[Specify your license here]

## Contributing

[Specify contribution guidelines here]
