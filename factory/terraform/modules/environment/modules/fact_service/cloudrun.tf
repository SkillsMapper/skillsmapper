resource "google_cloud_run_service" "fact_service" {
  depends_on = [google_secret_manager_secret_iam_member.fact_service_secret_accessor]
  name       = var.fact_service_name
  location   = var.region

  template {
    spec {
      service_account_name = "${var.fact_service_service_account_name}@${var.project_id}.iam.gserviceaccount.com"

      containers {
        image = "${var.region}-docker.pkg.dev/${var.management_project_id}/${var.container_repo}/${var.fact_service_name}:${var.fact_service_version}"
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }

        dynamic "env" {
          for_each = local.env_vars
          content {
            name  = env.value["name"]
            value = env.value["value"]
          }
        }

        env {
          name = "DATABASE_PASSWORD"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.secret.secret_id
              key  = "1"
            }
          }
        }
      }
    }
    metadata {
      annotations = {
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.instance.connection_name
      }
    }
  }
}

locals {
  env_vars = [
    {
      name  = "PROJECT_ID"
      value = var.project_id
    },
    {
      name  = "SERVICE_NAME"
      value = var.fact_service_name
    },
    {
      name  = "SPRING_PROFILES_ACTIVE"
      value = "gcp"
    },
    {
      name  = "DATABASE_USER"
      value = var.fact_database_user
    },
    {
      name  = "DATABASE_NAME"
      value = var.fact_database_name
    },
    {
      name  = "DATABASE_CONNECTION_NAME"
      value = "${var.project_id}:${var.region}:${var.fact_database_instance}"
    },
    {
      name  = "FACT_CHANGED_TOPIC"
      value = var.fact_changed_topic
    },
    {
      name  = "LOGGING_LEVEL_ORG_SKILLSMAPPER"
      value = "DEBUG"
    },
  ]
}
