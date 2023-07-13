resource "google_service_account" "skill_service_sa" {
  project      = var.project_id
  account_id   = "${var.skill_service_name}-sa"
  display_name = "Service account for ${var.skill_service_name}"
}

resource "google_storage_bucket_iam_binding" "skill_service_object_viewer" {
  bucket  = var.bucket_name
  role    = "roles/storage.objectViewer"
  members = [
    "serviceAccount:${google_service_account.skill_service_sa.email}",
  ]
}

resource "google_project_iam_member" "skill_service_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.skill_service_sa.email}"
}

resource "google_project_iam_member" "skill_service_cloudtrace_agent" {
  project = var.project_id
  role    = "roles/cloudtrace.agent"
  member  = "serviceAccount:${google_service_account.skill_service_sa.email}"
}
