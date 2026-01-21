# vlan

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_latitudesh"></a> [latitudesh](#requirement\_latitudesh) | ~> 2.8.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_latitudesh"></a> [latitudesh](#provider\_latitudesh) | ~> 2.8.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [latitudesh_virtual_network.virtual_network](https://registry.terraform.io/providers/latitudesh/latitudesh/latest/docs/resources/virtual_network) | resource |
| [latitudesh_vlan_assignment.vlan_assignment](https://registry.terraform.io/providers/latitudesh/latitudesh/latest/docs/resources/vlan_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"SAO2"` | no |
| <a name="input_server_ids"></a> [server\_ids](#input\_server\_ids) | n/a | `map(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `list(string)` | n/a | yes |
| <a name="input_vlan_description"></a> [vlan\_description](#input\_vlan\_description) | n/a | `string` | `"Virtual Network description"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
