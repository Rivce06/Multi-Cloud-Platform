include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  project_id = include.root.inputs.gcp_project_id
  region     = include.root.inputs.gcp_region
}

terraform {
  source = "."
}

inputs = {
  project_id = local.project_id
  location   = local.region

  format        = "DOCKER"
  repository_id = "platform-images"
  description   = "Docker images for platform workloads"

  cleanup_policies = [
    {
      id     = "delete-old-images"
      action = "DELETE"
      condition = {
        tag_state    = "ANY"
        older_than   = "7d"
      }
    }
  ]
}
