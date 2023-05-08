terraform {
  required_version = ">= 1.0"
}

module "tag_updater" {
  source = "./modules/tag_updater"
  project_id = var.project_id
}

module "skill_service" {
  source = "./modules/skill_service"
}

module "fact_service" {
  source = "./modules/fact_service"
}

module "profile_service" {
  source = "./modules/profile_service"
}

module "user_interface" {
  source = "./modules/user_interface"
}
