include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "envcommon_np" {
  path   = "${get_terragrunt_dir()}/../../../../_envcommon/gke-nodepool.hcl"
  expose = true
}

dependency "gke_cluster" {
  config_path = "../cluster"

  mock_outputs = {
    name       = "gke-test"
    location   = "us-central1"
    project_id = "test-project"
  }

  mock_outputs_allowed_terraform_commands = [
    "validate",
    "plan"
  ]
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env      = local.env_vars.locals.environment

  node_count   = try(local.env_vars.locals.gke_node_count, 1)
  machine_type = try(local.env_vars.locals.gke_machine_type, "e2-standard-2")
}

inputs = merge(
  include.envcommon_np.inputs,
  {
    project_id   = include.root.inputs.gcp_project_id
    cluster_name = dependency.gke_cluster.outputs.name
    location     = dependency.gke_cluster.outputs.location
    name         = "${include.root.inputs.project_name}-${local.env}-np-01"

    node_count   = local.node_count
    machine_type = local.machine_type
    spot         = true

    node_labels = {
      env        = local.env
      managed_by = "terragrunt"
    }
  }
)
