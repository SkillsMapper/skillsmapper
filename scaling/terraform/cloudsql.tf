resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database" "database" {
  name       = var.database_name
  instance   = google_sql_database_instance.instance.name
}

resource "google_sql_database_instance" "instance" {
  name             = "postgres-instance-${random_id.db_name_suffix.hex}"
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier              = var.database_tier
    availability_type = "REGIONAL"
    disk_size         = var.database_disk_size
    backup_configuration {
      enabled = true
    }
    ip_configuration {
      authorized_networks {
        value = var.local_ip_range
      }
      ipv4_enabled = true
    }
  }
  deletion_protection = "false"
}

resource "google_sql_user" "user" {
  name     = var.database_username
  instance = google_sql_database_instance.instance.name
  password = var.database_password
}

output "cloud_sql_instance_name" {
  value = google_sql_database_instance.instance.name
}

