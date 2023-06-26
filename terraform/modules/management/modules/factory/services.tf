resource "google_project_service" "secret_manager" {
  project = var.project_id
  service = "secretmanager.googleapis.com"
  disable_on_destroy         = false
}

resource "google_project_service" "cloudbuild" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"
  disable_on_destroy         = false
}

resource "google_project_service" "artifactregistry" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
  disable_on_destroy         = false
}

resource "google_project_service" "clouddeploy" {
  project = var.project_id
  service = "clouddeploy.googleapis.com"
  disable_on_destroy         = false
}

