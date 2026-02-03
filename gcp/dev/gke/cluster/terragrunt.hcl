include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "envcommon_gke" {
  path   = "${get_terragrunt_dir()}/../../../../_envcommon/gke.hcl"
  expose = true
}

dependency "vpc" {
  config_path = "../../vpc"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env      = local.env_vars.locals.environment
  region   = local.env_vars.locals.gcp_region
  zone     = "${local.region}-a"
}

inputs = {
  project_id = include.root.inputs.gcp_project_id

  name   = "${include.root.inputs.project_name}-${local.env}-gke"
  region = local.region
  zones  = [local.zone]

  network    = dependency.vpc.outputs.network_name
  subnetwork = dependency.vpc.outputs.subnets_names[0]

  ip_range_pods     = "pods"
  ip_range_services = "services"

  cluster_resource_labels = merge(
    include.envcommon_gke.inputs.cluster_resource_labels,
    {
      mesh_id = "proj-${include.root.inputs.gcp_project_id}"
      env     = local.env
    }
  )
}