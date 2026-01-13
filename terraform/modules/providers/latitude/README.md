# Latitude.sh Terraform Modules

This directory contains reusable Terraform modules for provisioning infrastructure on Latitude.sh.

## Module Structure

```
latitude/
├── bare-metal-server/      # Provisions bare-metal servers
├── firewall/               # Creates firewall rules
├── firewall-assignment/    # Assigns firewalls to servers
├── virtual-network/        # Creates virtual networks (VLANs)
└── kubernetes-nodes/       # Main module combining all sub-modules for K8s
```

## Sub-Modules

### bare-metal-server

Provisions a single bare-metal server with configurable specifications.

**Key Features**:
- Dynamic hostname configuration
- Customizable server plans
- SSH key management
- Tag support

### firewall

Creates firewall configurations with custom rules.

**Key Features**:
- Protocol-based rules (TCP, UDP, ICMP)
- Port specifications
- Source IP restrictions

### firewall-assignment

Assigns firewall rules to servers.

**Key Features**:
- Links firewall to server
- Automatic dependency handling

### virtual-network

Creates virtual networks (VLANs) for private networking.

**Key Features**:
- Site-specific VLAN creation
- Tag support
- Automatic VLAN ID assignment

## Main Module: kubernetes-nodes

Combines all sub-modules to provision a complete Kubernetes cluster infrastructure.

**Features**:
- Dynamic master and worker node creation
- Automatic naming convention
- Pre-configured Kubernetes firewall rules
- Virtual network for cluster
- Scalable architecture

**Usage Example**:

```hcl
module "k8s_cluster" {
  source = "./modules/providers/latitude/kubernetes-nodes"

  cluster_name = "production"
  project      = "your-project-id"
  site         = "SAO"
  ssh_keys     = ["ssh-key-id"]

  master_nodes = [
    { plan = "c2-small-x86" },
    { plan = "c2-small-x86" },
    { plan = "c2-small-x86" }
  ]

  worker_nodes = [
    { plan = "c2-medium-x86" },
    { plan = "c2-medium-x86" }
  ]

  common_tags = ["production", "k8s"]
}
```

## Server Naming Convention

The kubernetes-nodes module automatically names servers:
- **Masters**: `{cluster_name}-master-{index}`
- **Workers**: `{cluster_name}-worker-{index}`

Example: `production-master-1`, `production-worker-1`

## Available Latitude.sh Sites

- **SAO**: São Paulo, Brazil
- **MIA**: Miami, USA
- **ASH**: Ashburn, USA

Check Latitude.sh documentation for current availability.

## Common Server Plans

- **c2-small-x86**: 4 vCPU, 8GB RAM
- **c2-medium-x86**: 8 vCPU, 16GB RAM
- **c2-large-x86**: 16 vCPU, 32GB RAM
- **c2-xlarge-x86**: 32 vCPU, 64GB RAM

Refer to [Latitude.sh Plans](https://www.latitude.sh/pricing) for complete list.

## Required Provider Configuration

```hcl
terraform {
  required_providers {
    latitudesh = {
      source  = "latitudesh/latitudesh"
      version = "~> 2.8.3"
    }
  }
}

provider "latitudesh" {
  # Set via LATITUDESH_AUTH_TOKEN environment variable
}
```

## Getting Started

1. Install Terraform >= 1.5.0
2. Get API token from Latitude.sh
3. Export token: `export LATITUDESH_AUTH_TOKEN="your-token"`
4. Use modules in your configuration

## Contributing

When adding new modules:
1. Create a new directory
2. Include: `main.tf`, `variables.tf`, `outputs.tf`, `README.md`
3. Follow existing naming conventions
4. Document all variables and outputs

## References

- [Latitude.sh Provider Documentation](https://registry.terraform.io/providers/latitudesh/latitudesh/latest/docs)
- [Terraform Module Best Practices](https://www.terraform.io/docs/modules/index.html)
