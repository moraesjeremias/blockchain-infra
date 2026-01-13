module "k8s-control-plane" {
  source       = "../../../../modules/providers/latitude/bare-metal-server"
  os           = "ubuntu_24_04_x64_lts"
  project      = data.google_secret_manager_secret_version.latitude_project_id.secret_data
  ssh_key_slug = "latitude_ssh_key"
  node_count   = 2
  region       = "NYC"
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
  region        = "NYC"
  hostname      = "worker"
  tags          = ["role:worker"]
}
