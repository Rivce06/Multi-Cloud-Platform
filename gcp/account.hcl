locals {
  gcp_project_id        = get_env("GCP_PROJECT_ID", "")
  gcp_service_account   = get_env("GCP_SERVICE_ACCOUNT", "")
  gcp_workload_provider = get_env("GCP_WORKLOAD_PROVIDER", "")
  gcp_region            = get_env("GCP_REGION", "us-central1")
}
