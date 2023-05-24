resource "google_sql_database_instance" "instance" {
  project          = var.project_id
  name             = var.instance_name
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = var.database_tier

    backup_configuration {
      enabled = true
    }

    location_preference {
      zone = "${var.region}-a"
    }

    disk_autoresize = true
    disk_size       = var.disk_size
    disk_type       = "PD_SSD"

    availability_type = "REGIONAL"

  }
}

resource "google_sql_database" "database" {
  project  = var.project_id
  instance = google_sql_database_instance.instance.name
  name     = var.database_name
}

resource "google_sql_user" "fact_service_user" {
  project  = var.project_id
  instance = google_sql_database_instance.instance.name
  name     = var.fact_service_user
  password = random_password.database_password.result
}
