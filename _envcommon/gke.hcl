terraform {
  source = "tfr:///terraform-google-modules/kubernetes-engine/google?version=43.0.0"
}

locals {
  gcp_project_id = get_env("GCP_PROJECT_ID", "")
}

inputs = {
  network           = "${local.env}-vpc"
  subnetwork        = "${local.env}-subnet-gke"
  ip_range_pods     = "pods"
  ip_range_services = "services"

  release_channel          = "REGULAR"
  deletion_protection      = false
  remove_default_node_pool = true
  initial_node_count       = 1

  enable_private_endpoint = false
  enable_private_nodes    = false
  network_policy          = true
  datapath_provider       = "ADVANCED_DATAPATH"

  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  workload_identity_enabled  = true
  identity_namespace         = "${local.gcp_project_id}.svc.id.goog"

  enable_identity_service = true

  logging_service    = "none"
  monitoring_service = "none"

  grant_registry_access         = true
  monitoring_enabled_components = []

  cluster_resource_labels = {
    managed_by = "terragrunt"
  }

  master_authorized_networks = [
    {
      cidr_block   = "${get_env("AUTHORIZED_NETWORK", "1.1.1.1")}/32"
      display_name = "Authorized Network IP"
    }
  ]
}
