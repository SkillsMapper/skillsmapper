variable "skill_service_name" {
  type = string
}

variable "skill_service_service_account_name" {
  default = "skill-service-sa"
  type    = string
}

variable "project_id" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "tags_file_name" {
  type = string
}

variable "region" {
  type = string
}

variable "management_project_id" {
  type = string
}

variable "skill_service_version" {
  type = string
}

variable "container_repo" {
  type = string
}
