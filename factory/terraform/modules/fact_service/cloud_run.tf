resource "google_cloud_run_service" "fact_service" {
  name     = var.fact_service_name
  location = var.region

  template {
    spec {
      service_account_name = "${var.fact_service_service_account_name}@${var.project_id}.iam.gserviceaccount.com"

      containers {
        image = "gcr.io/${var.project_id}/${var.fact_service_name}:latest"

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
              name = "${var.project_id}/secrets/${var.secret_name}/versions/latest"
              key  = "secret_data"
            }
          }
        }
      }
    }
  }

  metadata {
    annotations = {
      "run.googleapis.com/cloudsql-instances" = "${var.project_id}:${var.region}:${google_sql_database_instance.instance.name}"
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
      value = var.fact_service_user
    },
    {
      name  = "DATABASE_NAME"
      value = var.database_name
    },
    {
      name  = "DATABASE_CONNECTION_NAME"
      value = "${var.project_id}:${var.region}:${google_sql_database_instance.instance.name}"
    },
    {
      name  = "FACT_CHANGED_TOPIC"
      value = "fact-changed"
    },
    {
      name  = "LOGGING_LEVEL_ORG_SKILLSMAPPER"
      value = "DEBUG"
    },
  ]
}
