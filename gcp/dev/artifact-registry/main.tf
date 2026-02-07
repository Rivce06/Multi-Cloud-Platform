resource "google_artifact_registry_repository" "repo" {
  project       = var.project_id
  location      = var.location
  repository_id = var.repository_id
  description   = var.description
  format        = var.format

  dynamic "cleanup_policies" {
    for_each = var.cleanup_policies
    content {
      id     = cleanup_policies.value.id
      action = cleanup_policies.value.action
      condition {
        tag_state  = cleanup_policies.value.condition.tag_state
        older_than = cleanup_policies.value.condition.older_than
      }
    }
  }
}
