terraform {
  required_version = ">= 1.0"
}

module "tag_updater" {
  source         = "./modules/tag_updater"
  project_id     = var.project_id
  region         = var.region
  bucket_name    = var.bucket_name
  tags_file_name = var.tags_file_name
}

module "skill_service" {
  source             = "./modules/skill_service"
  project_id         = var.project_id
  region             = var.region
  bucket_name        = var.bucket_name
  tags_file_name     = var.tags_file_name
  skill_service_name = var.skill_service_name
}


module "fact_service" {
  source             = "./modules/fact_service"
  project_id         = var.project_id
  region             = var.region
  fact_changed_topic = var.fact_changed_topic
  fact_service_name  = var.fact_service_name
}

module "profile_service" {
  source               = "./modules/profile_service"
  project_id           = var.project_id
  region               = var.region
  fact_changed_topic   = var.fact_changed_topic
  profile_service_name = var.profile_service_name
}

module "user_interface" {
  source     = "./modules/user_interface"
  prefix     = var.prefix
  project_id = var.project_id
  region     = var.region
}

module "citadel" {
  source               = "./modules/citadel"
  project_id           = var.project_id
  region               = var.region
  domain               = var.domain
  profile_service_name = var.profile_service_name
  fact_service_name    = var.fact_service_name
  skill_service_name   = var.skill_service_name
  api_name             = "${var.prefix}-api"
  prefix               = var.prefix
}
