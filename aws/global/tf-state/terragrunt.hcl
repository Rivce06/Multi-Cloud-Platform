include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "tfr:///terraform-aws-modules/s3-bucket/aws?version=5.10.0"
}

inputs = {
  bucket = "terraform-state-${include.root.locals.project_name}-${include.root.locals.env}"
  versioning = {
    enabled = true
  }
}