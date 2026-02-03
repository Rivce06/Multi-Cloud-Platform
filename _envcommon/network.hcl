terraform {
  source = "tfr:///terraform-google-modules/network/google//?version=13.1.0"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env      = local.env_vars.locals.environment
  region   = local.env_vars.locals.gcp_region
}

inputs = {
  network_name = "${local.env}-vpc"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = "${local.env}-subnet-gke"
      subnet_ip     = "10.0.0.0/20"
      subnet_region = local.region
    }
  ]

  secondary_ranges = {
    "${local.env}-subnet-gke" = [
      {
        range_name    = "pods"
        ip_cidr_range = "10.1.0.0/16"
      },
      {
        range_name    = "services"
        ip_cidr_range = "10.2.0.0/20"
      },
    ]
  }
}