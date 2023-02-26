resource "google_service_account" "gcf_invoker_sa" {
  account_id   = "gcf-invoker-sa"
  display_name = "Test Service Account - used for both the cloud function"
}

resource "google_service_account" "gcf_sa" {
  account_id   = "gcf-sa"
  display_name = "Test Service Account - used for both the cloud function"
}

resource "google_project_iam_member" "invoking_binding" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.gcf_invoker_sa.email}"
}

resource "google_project_iam_member" "bigquery_binding" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.gcf_sa.email}"
}

resource "google_storage_bucket_iam_binding" "cloudstorage_binding" {
  bucket  = google_storage_bucket.tags_bucket.name
  role    = "roles/storage.admin"
  members = ["serviceAccount:${google_service_account.gcf_sa.email}"]
}
