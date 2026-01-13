terraform {
  required_version = ">= 1.13.5"
  backend "gcs" {
    bucket = "blokchain-terraform-states"
    prefix = "sandbox/latitude/servers"
  }
  required_providers {
    latitudesh = {
      source  = "latitudesh/latitudesh"
      version = "~> 2.8.3"
    }
    google = {
      version = "~> 7.12.0"
    }
  }
}
