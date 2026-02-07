terraform {
  source = "tfr:///terraform-google-modules/kubernetes-engine/google//modules/gke-node-pool?version=43.0.0"
}

inputs = {
  machine_type = try(local.env_vars.locals.gke_machine_type, "e2-standard-2")
  spot         = true

  disk_size_gb = 50
  disk_type    = "pd-balanced"
  image_type   = "COS_CONTAINERD"

  auto_repair  = true
  auto_upgrade = true

  node_metadata = "GKE_METADATA_SERVER"

  oauth_scopes = [
    "https://www.googleapis.com/auth/cloud-platform"
  ]

  node_labels = {
    managed_by = "terragrunt"
  }
}
