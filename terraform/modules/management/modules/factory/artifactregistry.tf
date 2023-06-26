resource "google_artifact_registry_repository" "repository" {
  location      = var.region
  repository_id = var.container_repo
  format        = "DOCKER"

  docker_config {
    immutable_tags = true
  }
}
