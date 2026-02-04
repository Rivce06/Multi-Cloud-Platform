include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "envcommon" {
  path = "${get_terragrunt_dir()}/../../../../_envcommon/argocd.hcl"
}

dependency "gke" {
  config_path = "../../gke/cluster"
}

dependency "node_pools" {
  config_path = "../../gke/node-pools"
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
data "google_client_config" "default" {}

provider "random" {}

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