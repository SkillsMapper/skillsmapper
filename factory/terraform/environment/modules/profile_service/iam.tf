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
  member   = "serviceAccount:${google_service_account.fact_changed_subscription_sa.account_id}@${var.project_id}.iam.gserviceaccount.com"
}

