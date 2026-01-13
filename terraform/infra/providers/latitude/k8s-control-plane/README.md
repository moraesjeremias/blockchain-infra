# k8s-control-plane

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 7.12.0 |
| <a name="requirement_latitudesh"></a> [latitudesh](#requirement\_latitudesh) | ~> 2.8.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 7.12.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_k8s-control-plane"></a> [k8s-control-plane](#module\_k8s-control-plane) | ../../../../modules/providers/latitude/bare-metal-server | n/a |
| <a name="module_k8s-worker"></a> [k8s-worker](#module\_k8s-worker) | ../../../../modules/providers/latitude/bare-metal-server | n/a |

## Resources

| Name | Type |
|------|------|
| [google_secret_manager_secret_version.latitude_project_id](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/secret_manager_secret_version) | data source |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
