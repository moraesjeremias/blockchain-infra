resource "latitudesh_server" "server" {
  count            = var.node_count
  billing          = "hourly"
  hostname         = "${var.hostname}-${count.index + 1}"
  plan             = var.instance_type
  site             = var.region
  operating_system = var.os
  project          = var.project
  ssh_keys         = [data.latitudesh_ssh_key.default_ssh_key.id]
  #   tags = var.tags
}

# Access the server's attributes
output "server" {
  value = latitudesh_server.server
}
