terraform {
  required_version = ">= 1.0"
}

module "tag_updater" {
  source         = "./modules/tag_updater"
  providers = {
    google = google
  }
  project_id     = var.project_id
  region         = var.region
  bucket_name    = var.tag_bucket_name
  tags_file_name = var.tags_file_name
}

module "skill_service" {
  source             = "./modules/skill_service"
  providers = {
    google = google
  }
  project_id         = var.project_id
  region             = var.region
  bucket_name        = var.tag_bucket_name
  tags_file_name     = var.tags_file_name
  skill_service_name = var.skill_service_name
  depends_on         = [module.tag_updater]
}


module "fact_service" {
  source             = "./modules/fact_service"
  providers = {
    google = google
  }
  project_id         = var.project_id
  region             = var.region
  fact_changed_topic = var.fact_changed_topic
  fact_service_name  = var.fact_service_name
  depends_on         = [module.skill_service]
}

module "profile_service" {
  source                    = "./modules/profile_service"
  providers = {
    google = google
  }
  project_id                = var.project_id
  region                    = var.region
  fact_changed_topic        = var.fact_changed_topic
  profile_service_name      = var.profile_service_name
  fact_changed_subscription = var.fact_changed_subscription
  depends_on                = [module.fact_service]
}

module "user_interface" {
  source     = "./modules/user_interface"
  providers = {
    google = google
  }
  prefix     = var.prefix
  project_id = var.project_id
  region     = var.region
  depends_on = [module.profile_service, module.fact_service, module.skill_service]
}

module "citadel" {
  source    = "./modules/citadel"
  providers = {
    google-beta = google-beta
  }
  project_id                = var.project_id
  region                    = var.region
  domain                    = var.domain
  profile_service_name      = var.profile_service_name
  fact_service_name         = var.fact_service_name
  skill_service_name        = var.skill_service_name
  api_name                  = "${var.prefix}-api"
  prefix                    = var.prefix
  fact_changed_subscription = var.fact_changed_subscription
  depends_on                = [module.user_interface]
}
