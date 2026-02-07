locals {
  project_name = get_env("PROJECT_NAME", "multi-cloud-platform")
  aws_region   = get_env("AWS_REGION", "us-east-1")
  gcp_project_id = get_env("GCP_PROJECT_ID", "")
}
