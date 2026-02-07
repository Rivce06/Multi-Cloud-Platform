include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "gke" {
  config_path  = "../gke/cluster"
  skip_outputs = true
}

locals {
  project_id = include.root.inputs.gcp_project_id
  env        = include.root.inputs.environment
}

terraform {
  source = "tfr:///terraform-google-modules/service-accounts/google?version=4.4.0"
}

inputs = {
  project_id = local.project_id
  names      = ["gke-workloads"]
  project_roles = [
    "${local.project_id}=>roles/artifactregistry.reader",
    "${local.project_id}=>roles/logging.logWriter",
    "${local.project_id}=>roles/monitoring.metricWriter"
  ]

  generate_iam_policy_bindings = true
  bindings = {
    "roles/iam.workloadIdentityUser" = [
      "serviceAccount:${local.project_id}.svc.id.goog[argocd/argocd-manager]"
    ]
  }
}
