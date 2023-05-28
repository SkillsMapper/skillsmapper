variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "database_name" {
  default = "(default)"
  type    = string
}

variable "fact_changed_topic" {
  type = string
}

variable "profile_service_name" {
  type = string
}

variable "profile_service_version" {
  type = string
}

variable "fact_changed_subscription" {
  type = string
}

variable "management_project_id" {
  type = string
}
