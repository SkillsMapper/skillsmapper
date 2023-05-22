module "factory" {
  source = "./modules/factory"
  providers = {
    google = google
  }
  project_id = data.google_project.project.project_id
  project_number = data.google_project.project.number
  region = var.region
  app_installation_id = var.app_installation_id
}

module "observatory" {
  source = "./modules/observatory"
  providers = {
    google = google
  }
  project_id = data.google_project.project.project_id
}

data "google_project" "project" {
  project_id      = var.project_id
}
