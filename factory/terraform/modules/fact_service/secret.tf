resource "random_password" "database_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "google_secret_manager_secret" "secret" {
  depends_on = [google_project_service.secret_manager]
  project   = var.project_id
  secret_id = var.secret_name
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "secret_version" {
  secret = google_secret_manager_secret.secret.name
  secret_data = random_password.database_password.result
}
