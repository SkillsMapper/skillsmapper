variable "skill_service_name" {
  type = string
}

variable "image_name" {
  default = "skill-service"
  type    = string
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
