module "application" {
  source     = "./modules/application"
  depends_on = [module.management]
  providers = {
    google      = google.application
    google-beta = google-beta.application
  }
  project_id              = google_project.application_project.project_id
  api_key                 = var.api_key
  domain                  = var.domain
  prefix                  = var.prefix
  fact_service_name       = var.fact_service_name
  profile_service_name    = var.profile_service_name
  skill_service_name      = var.skill_service_name
  region                  = var.region
  management_project_id   = var.management_project_id
  skill_service_version   = var.skill_service_dev_version
  fact_service_version    = var.fact_service_dev_version
  profile_service_version = var.profile_service_dev_version
  container_repo          = var.container_repo
  project_name            = var.application_project_name
  profile_database_name   = var.profile_database_name
  fact_database_name      = var.fact_database_name
  fact_database_user      = var.fact_database_user
  skill_service_max_instances = var.skill_service_max_instances
  skill_service_min_instances = var.skill_service_min_instances
  fact_service_max_instances = var.fact_service_max_instances
  fact_service_min_instances = var.fact_service_min_instances
  profile_service_max_instances = var.profile_service_max_instances
  profile_service_min_instances = var.profile_service_min_instances
}

provider "google" {
  alias   = "application"
  project = var.application_project_id
  region  = var.region
}

provider "google-beta" {
  alias   = "application"
  project = var.application_project_id
  region  = var.region
}

resource "google_project" "application_project" {
  project_id      = var.application_project_id
  name            = var.application_project_name
  billing_account = var.billing_account
  labels = {
    "firebase" = "enabled"
  }
}
