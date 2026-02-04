locals {
  environment = get_env("ENVIRONMENT", "dev")
  gcp_region  = get_env("GCP_REGION", "us-central1")

  gke_node_count   = 1
  gke_machine_type = "e2-standard-4"

  enable_autopilot = false
}