data "google_secret_manager_secret_version" "latitude_project_id" {
  secret  = "latitude_project_id"
  project = "moraesjeremias-studies"
}
