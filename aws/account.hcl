locals {
  aws_account_id     = get_env("AWS_ACCOUNT_ID", "")
  aws_role_to_assume = get_env("AWS_ROLE_TO_ASSUME", "")
}
