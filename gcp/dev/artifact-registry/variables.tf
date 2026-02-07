variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "GCP region"
  type        = string
}

variable "repository_id" {
  description = "Artifact Registry repo name"
  type        = string
}

variable "format" {
  description = "Repo format"
  type        = string
  default     = "DOCKER"
}

variable "description" {
  description = "Repo description"
  type        = string
  default     = "Managed by Terragrunt"
}

variable "cleanup_policies" {
  description = "Policies list"
  type        = any
  default     = []
}
