variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "database_name" {
  default = "profiles"
  type    = string
}

variable "fact_changed_topic" {
  type = string
}

variable "profile_service_name" {
  type = string
}

variable "image_name" {
  default = "profile-service"
  type    = string
}

variable "fact_changed_subscription" {
  type = string
}
