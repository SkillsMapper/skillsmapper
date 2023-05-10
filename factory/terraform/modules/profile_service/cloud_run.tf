resource "google_cloud_run_service" "profile_service" {
  name     = var.profile_service_name
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/${var.image_name}:latest"

        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }

        env {
          name  = "DATABASE_NAME"
          value = var.database_name
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

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.profile_service.location
  project  = google_cloud_run_service.profile_service.project
  service  = google_cloud_run_service.profile_service.name

  policy_data = data.google_iam_policy.no_auth.policy_data
}

data "google_iam_policy" "no_auth" {
  binding {
    role = "roles/run.invoker"

    members = [
      "allUsers",
    ]
  }
}
