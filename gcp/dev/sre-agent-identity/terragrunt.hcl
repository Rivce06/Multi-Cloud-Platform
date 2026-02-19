include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "gke" {
  config_path = "../gke/cluster"
}

terraform {
  source = "tfr:///terraform-google-modules/kubernetes-engine/google//modules/workload-identity?version=43.0.0"
}

inputs = {
  project_id  = include.root.inputs.gcp_project_id
  name        = "sre-agent"
  namespace   = "sre-workloads"
  k8s_sa_name = "sre-agent-sa"

  use_existing_k8s_sa = true

  roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/artifactregistry.reader",
    "roles/aiplatform.user"
  ]
}

output "gcp_service_account_email" {
  value = module.workload_identity.gcp_service_account_email
}
