
resource "google_service_account" "gateway" {
  account_id   = "${var.api_name}-gateway-sa"
  display_name = "Service account to invoke ${var.api_name} services"
  project      = var.project_id
}

resource "google_cloud_run_service_iam_binding" "skill_service_invoker" {
  project  = var.project_id
  location = var.region
  service  = data.google_cloud_run_service.skill_service.name

  role = "roles/run.invoker"

  members = [
    "serviceAccount:${var.api_name}-gateway-sa@${var.project_id}.iam.gserviceaccount.com",
  ]
}

resource "google_cloud_run_service_iam_binding" "fact_service_invoker" {
  project  = var.project_id
  location = var.region
  service  = data.google_cloud_run_service.fact_service.name

  role = "roles/run.invoker"

  members = [
    "serviceAccount:${var.api_name}-gateway-sa@${var.project_id}.iam.gserviceaccount.com",
  ]
}

resource "google_cloud_run_service_iam_binding" "profile_service_invoker" {
  project  = var.project_id
  location = var.region
  service  = data.google_cloud_run_service.profile_service.name

  role = "roles/run.invoker"

  members = [
    "serviceAccount:${var.api_name}-gateway-sa@${var.project_id}.iam.gserviceaccount.com",
    "serviceAccount:${var.fact_changed_subscription}-sa@${var.project_id}.iam.gserviceaccount.com"
  ]
}
