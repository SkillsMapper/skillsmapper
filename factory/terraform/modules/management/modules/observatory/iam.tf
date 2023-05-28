resource "google_service_account" "monitoring_sa" {
  account_id   = "monitoring-sa"
  display_name = "Monitoring Service Account"
  project      = var.project_id
}

resource "google_project_iam_member" "monitoring_sa_monitoring_editor" {
  project = var.project_id
  role    = "roles/monitoring.editor"
  member  = "serviceAccount:${google_service_account.monitoring_sa.email}"
}

resource "google_project_iam_member" "monitoring_sa_dev_viewer" {
  project = var.dev_project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.monitoring_sa.email}"
}

output "monitoring_sa_email" {
  value = google_service_account.monitoring_sa.email
}
