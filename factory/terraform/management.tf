module "management" {
  source              = "./modules/management"
  app_installation_id = var.app_installation_id
  github_repo         = var.github_repo
  dev_project_id      = google_project.dev_project.project_id
  project_id          = google_project.management_project.project_id
  region              = var.region
  service_names       = var.service_names
  container_repo      = var.container_repo
  github_token        = var.github_token
}

resource "google_project" "management_project" {
  project_id      = var.management_project_id
  name            = var.management_project_name
  billing_account = var.billing_account
}
