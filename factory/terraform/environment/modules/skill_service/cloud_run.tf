resource "google_cloud_run_service" "skill_service" {
  name     = var.skill_service_name
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.skill_service.email
      containers {
        image = "gcr.io/${var.project_id}/${var.image_name}:latest"

        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }

        env {
          name  = "BUCKET_NAME"
          value = "${var.project_id}-${var.bucket_name}"
        }

        env {
          name  = "OBJECT_NAME"
          value = var.tags_file_name
        }

        env {
          name  = "SERVICE_NAME"
          value = var.skill_service_name
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_project_service.cloud_run,
    google_project_service.container_registry,
  ]
}
