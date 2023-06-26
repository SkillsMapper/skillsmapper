resource "google_service_account" "profile_service_sa" {
  project      = var.project_id
  account_id   = "${var.profile_service_name}-sa"
  display_name = "Service account for ${var.profile_service_name}"
}

resource "google_project_iam_member" "project" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.profile_service_sa.email}"
}

resource "google_project_iam_member" "skill_service_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.profile_service_sa.email}"
}

resource "google_service_account" "fact_changed_subscription_sa" {
  project      = var.project_id
  account_id   = "${var.fact_changed_subscription}-sa"
  display_name = "Service account for ${var.fact_changed_subscription}"
}

resource "google_cloud_run_service_iam_member" "fact_changed_invoker" {
  project  = var.project_id
  location = var.region
  service  = google_cloud_run_service.profile_service.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.fact_changed_subscription_sa.email}"
}

