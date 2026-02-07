include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "envcommon" {
  path = "${get_terragrunt_dir()}/../../../../_envcommon/argocd.hcl"
}

dependency "gke" {
  config_path = "../../gke/cluster"

  mock_outputs = {
    endpoint       = "1.2.3.4"
    ca_certificate = base64encode("fake-cert")
  }

  mock_outputs_allowed_terraform_commands = [
    "validate",
    "plan"
  ]
}

dependency "node_pools" {
  config_path  = "../../gke/node-pools"
  skip_outputs = true
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
data "google_client_config" "default" {}

provider "helm" {
  kubernetes {
    host                   = "https://${dependency.gke.outputs.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode("${dependency.gke.outputs.ca_certificate}")
  }
}
EOF
}