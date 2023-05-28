resource "google_artifact_registry_repository" "repository" {
  for_each = toset(var.service_names)

  location      = var.region
  repository_id = each.key
  format        = "DOCKER"

  docker_config {
    immutable_tags = true
  }
}
