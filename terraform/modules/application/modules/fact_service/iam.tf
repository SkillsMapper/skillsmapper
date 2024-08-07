resource "google_service_account" "fact_service_sa" {
  project      = var.project_id
  account_id   = "${var.fact_service_name}-sa"
  display_name = "Service account for ${var.fact_service_name}"
}

resource "google_project_iam_member" "fact_service_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.fact_service_sa.email}"
}

resource "google_project_iam_member" "fact_service_cloudtrace_agent" {
  project = var.project_id
  role    = "roles/cloudtrace.agent"
  member  = "serviceAccount:${google_service_account.fact_service_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "fact_service_secret_accessor" {
  secret_id  = google_secret_manager_secret.secret.id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${google_service_account.fact_service_sa.email}"
  depends_on = [google_secret_manager_secret.secret]
}

resource "google_pubsub_topic_iam_member" "publisher" {
  project = var.project_id
  topic   = var.fact_changed_topic
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.fact_service_sa.email}"
}

