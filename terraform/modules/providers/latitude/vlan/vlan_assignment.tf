resource "latitudesh_vlan_assignment" "vlan_assignment" {
  for_each           = var.server_ids
  server_id          = each.value
  virtual_network_id = latitudesh_virtual_network.virtual_network.id
}
