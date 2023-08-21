terraform {
  required_version = ">= 0.12.0, < 2.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=4.63.1, < 5.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">=4.63.1, < 5.0.0"
    }
  }
}

data "external" "git_commit" {
  program = ["bash", "-c", "git log --pretty=format:'{ \"sha\": \"%H\" }' -1 HEAD"]
}

module "tag_updater" {
  source = "./modules/tag_updater"
  providers = {
    google = google
  }
  project_id     = var.project_id
  region         = var.region
  bucket_name    = "${var.project_id}-${var.tag_bucket_name}"
  tags_file_name = var.tags_file_name
}

module "skill_service" {
  source = "./modules/skill_service"
  providers = {
    google = google
  }
  project_id            = var.project_id
  management_project_id = var.management_project_id
  region                = var.region
  bucket_name           = "${var.project_id}-${var.tag_bucket_name}"
  tags_file_name        = var.tags_file_name
  skill_service_name    = var.skill_service_name
  skill_service_version = data.external.git_commit.result.sha
  container_repo        = var.container_repo
  depends_on            = [module.tag_updater]
  max_instances         = var.skill_service_max_instances
  min_instances         = var.skill_service_min_instances
}

module "fact_service" {
  source = "./modules/fact_service"
  providers = {
    google = google
  }
  project_id            = var.project_id
  management_project_id = var.management_project_id
  region                = var.region
  fact_changed_topic    = var.fact_changed_topic
  fact_service_name     = var.fact_service_name
  fact_service_version  = data.external.git_commit.result.sha
  container_repo        = var.container_repo
  depends_on            = [module.skill_service]
  fact_database_name    = var.fact_database_name
  fact_database_user    = var.fact_database_user
  max_instances         = var.fact_service_max_instances
  min_instances         = var.fact_service_min_instances
}

module "profile_service" {
  source = "./modules/profile_service"
  providers = {
    google = google
  }
  project_id                = var.project_id
  management_project_id     = var.management_project_id
  region                    = var.region
  fact_changed_topic        = var.fact_changed_topic
  profile_service_name      = var.profile_service_name
  profile_service_version   = data.external.git_commit.result.sha
  fact_changed_subscription = var.fact_changed_subscription
  container_repo            = var.container_repo
  depends_on                = [module.fact_service]
  profile_database_name     = var.profile_database_name
  max_instances             = var.profile_service_max_instances
  min_instances             = var.profile_service_min_instances
}

module "user_interface" {
  source = "./modules/user_interface"
  providers = {
    google = google
  }
  project_id = var.project_id
  region     = var.region
  api_key    = var.api_key
  depends_on = [module.profile_service, module.fact_service, module.skill_service]
}

module "citadel" {
  source = "./modules/citadel"
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
