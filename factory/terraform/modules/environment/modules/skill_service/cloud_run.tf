resource "google_cloud_run_service" "skill_service" {
  depends_on = [google_project_service.run]
  name       = var.skill_service_name
  location   = var.region

  template {
    spec {
      service_account_name = google_service_account.skill_service_sa.email
      containers {
        image = "${var.region}-docker.pkg.dev/${var.management_project_id}/${var.container_repo}/${var.skill_service_name}:${var.skill_service_version}"
        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }

        env {
          name  = "BUCKET_NAME"
          value = var.bucket_name
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
}
