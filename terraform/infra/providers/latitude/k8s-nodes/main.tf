module "k8s-control-plane" {
  source       = "../../../../modules/providers/latitude/bare-metal-server"
  os           = "ubuntu_24_04_x64_lts"
  project      = data.google_secret_manager_secret_version.latitude_project_id.secret_data
  ssh_key_slug = "latitude_ssh_key"
  node_count   = 3
  region       = local.region
  hostname     = "control-plane"
  tags         = ["role:control-plane"]
}

module "k8s-worker" {
  source        = "../../../../modules/providers/latitude/bare-metal-server"
  os            = "ubuntu_24_04_x64_lts"
  instance_type = "s2-small-x86"
  project       = data.google_secret_manager_secret_version.latitude_project_id.secret_data
  ssh_key_slug  = "latitude_ssh_key"
  node_count    = 1
  region        = local.region
  hostname      = "worker"
  tags          = ["role:worker"]
}

module "vlan" {
  source           = "../../../../modules/providers/latitude/vlan"
  vlan_description = "K8s VLAN"
  project          = data.google_secret_manager_secret_version.latitude_project_id.secret_data
  server_ids       = { for index, id in concat(module.k8s-worker.server_ids, module.k8s-control-plane.server_ids) : "server-${index}" => id }
  region           = local.region
  tags             = ["role:vlan", "domain:k8s"]
}
