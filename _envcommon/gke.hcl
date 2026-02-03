terraform {
  source = "tfr:///terraform-google-modules/kubernetes-engine/google?version=43.0.0"
}

inputs = {
  remove_default_node_pool = true
  initial_node_count       = 1

  enable_private_endpoint = false
  enable_private_nodes    = false

  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  workload_identity_enabled  = true
  identity_namespace         = "${local.gcp_project_id}.svc.id.goog"

  logging_service    = "none"
  monitoring_service = "none"

  grant_registry_access = true
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
