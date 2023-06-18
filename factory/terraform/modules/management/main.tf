module "factory" {
  source    = "./modules/factory"
  providers = {
    google = google
  }
  project_id          = var.project_id
  dev_project_id      = var.dev_project_id
  region              = var.region
  app_installation_id = var.app_installation_id
  github_repo         = var.github_repo
  service_names       = var.service_names
  container_repo      = var.container_repo
  github_token        = var.github_token
}

module "observatory" {
  source    = "./modules/observatory"
  providers = {
    google = google
  }
  project_id         = var.project_id
  dev_project_id     = var.dev_project_id
  region             = var.region
}

