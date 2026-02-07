locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"), { locals = {} })
  env_vars      = read_terragrunt_config(find_in_parent_folders("env.hcl"), { locals = {} })

  cloud = contains(split("/", get_terragrunt_dir()), "aws") ? "aws" : (
    contains(split("/", get_terragrunt_dir()), "gcp") ? "gcp" : "unknown"
  )

  project_name   = get_env("PROJECT_NAME", try(local.account_vars.locals.project_name, "Multi-Cloud-Platform"))
  env            = get_env("ENVIRONMENT", try(local.env_vars.locals.environment, "dev"))
  aws_region     = get_env("AWS_REGION", try(local.account_vars.locals.aws_region, "us-east-1"))
  gcp_region     = get_env("GCP_REGION", try(local.env_vars.locals.gcp_region, "us-central1"))
  gcp_project_id = get_env("GCP_PROJECT_ID", try(local.account_vars.locals.gcp_project_id, "my-project"))
}

# -------------------
# GENERATE PROVIDERS
# -------------------
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  default_tags {
    tags = {
      Project     = "${local.project_name}"
      Environment = "${local.env}"
      ManagedBy   = "Terragrunt"
    }
  }
}

%{ if local.cloud == "gcp" }
provider "google" {
  project = "${local.gcp_project_id}"
  region  = "${local.gcp_region}"
}
%{ endif }
EOF
}

# -------------
# REMOTE STATE
# -------------
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = lower("terraform-state-${local.project_name}-${local.env}")
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = "terraform-lock-${local.project_name}-${local.env}"
  }
}

# ---------------
# GLOBAL INPUTS
# ---------------
inputs = merge(
  local.account_vars.locals,
  local.env_vars.locals,
  {
    project_name   = local.project_name
    environment    = local.env
    aws_region     = local.aws_region
    gcp_region     = local.gcp_region
    gcp_project_id = local.gcp_project_id
  }
)