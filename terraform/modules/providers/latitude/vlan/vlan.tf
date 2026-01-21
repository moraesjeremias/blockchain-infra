resource "latitudesh_virtual_network" "virtual_network" {
  description = var.vlan_description
  site        = var.region
  project     = var.project
  tags        = var.tags
}
