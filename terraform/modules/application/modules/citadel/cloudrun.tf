data "google_cloud_run_service" "profile_service" {
  name     = var.profile_service_name
  project  = var.project_id
  location = var.region
}

data "google_cloud_run_service" "fact_service" {
  name     = var.fact_service_name
  project  = var.project_id
  location = var.region
}

data "google_cloud_run_service" "skill_service" {
  name     = var.skill_service_name
  project  = var.project_id
  location = var.region
}
