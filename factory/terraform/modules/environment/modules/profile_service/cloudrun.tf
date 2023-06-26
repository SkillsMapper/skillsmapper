resource "google_cloud_run_service" "profile_service" {
  name     = var.profile_service_name
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.profile_service_sa.email
      containers {
        image = "${var.region}-docker.pkg.dev/${var.management_project_id}/${var.container_repo}/${var.profile_service_name}:${var.profile_service_version}"
        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }

        env {
          name  = "DATABASE_NAME"
          value = var.profile_database_name
        }

        env {
          name  = "SERVICE_NAME"
          value = var.profile_service_name
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true
}
