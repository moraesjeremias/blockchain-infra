# bare-metal-server

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
| [latitudesh_server.server](https://registry.terraform.io/providers/latitudesh/latitudesh/latest/docs/resources/server) | resource |
| [latitudesh_ssh_key.default_ssh_key](https://registry.terraform.io/providers/latitudesh/latitudesh/latest/docs/data-sources/ssh_key) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_hostname"></a> [hostname](#input\_hostname) | n/a | `string` | `"sandbox-machine"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | n/a | `string` | `"c2-small-x86"` | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | n/a | `number` | `1` | no |
| <a name="input_os"></a> [os](#input\_os) | n/a | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"SAO2"` | no |
| <a name="input_ssh_key_slug"></a> [ssh\_key\_slug](#input\_ssh\_key\_slug) | n/a | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_server"></a> [server](#output\_server) | Access the server's attributes |
<!-- END_TF_DOCS -->
