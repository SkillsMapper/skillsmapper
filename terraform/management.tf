module "management" {
  source                     = "./modules/management"
  app_installation_id        = var.app_installation_id
  github_repo                = var.github_repo
  dev_project_id             = var.dev_project_id
  project_id                 = var.management_project_id
  region                     = var.region
  service_names              = var.service_names
  container_repo             = var.container_repo
  github_token               = var.github_token
  profile_database_name      = var.profile_database_name
  fact_changed_topic         = var.fact_changed_topic
  fact_database_instance     = var.fact_database_instance
  fact_database_name         = var.fact_database_name
  fact_database_user         = var.fact_database_user
  cloudbuild_connection_name = var.cloudbuild_connection_name
}

resource "google_project" "management_project" {
  project_id      = var.management_project_id
  name            = var.management_project_name
  billing_account = var.billing_account
}
