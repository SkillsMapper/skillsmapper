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
  source         = "./modules/skill_service"
  project_id     = var.project_id
  region         = var.region
  bucket_name    = var.bucket_name
  tags_file_name = var.tags_file_name
}

module "fact_service" {
  source     = "./modules/fact_service"
  project_id = var.project_id
  region     = var.region
}

module "profile_service" {
  source = "./modules/profile_service"
}

module "user_interface" {
  source = "./modules/user_interface"
}
