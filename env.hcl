locals {
  environment = get_env("ENVIRONMENT", "dev")
  aws_region   = get_env("AWS_REGION", "us-east-1")
}