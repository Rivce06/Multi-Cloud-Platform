include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "." 
}

dependency "gke" {
  config_path = "../../gke/cluster"
  mock_outputs = {
    endpoint       = "1.2.3.4"
    ca_certificate = base64encode("fake-cert")
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "node_pools" {
  config_path  = "../../gke/node-pools"
  skip_outputs = true
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${dependency.gke.outputs.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode("${dependency.gke.outputs.ca_certificate}")
}

provider "helm" {
  kubernetes {
    host                   = "https://${dependency.gke.outputs.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode("${dependency.gke.outputs.ca_certificate}")
  }
}
EOF
}

inputs = {
  chart_version = "7.7.0"
}