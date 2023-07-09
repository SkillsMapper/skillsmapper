variable "project_id" {
  type        = string
  description = "The ID of the Google Cloud project."
}

variable "dev_project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "fact_service_name" {
  type    = string
  default = "fact-service"
}

variable "skill_service_name" {
  type    = string
  default = "skill-service"
}

variable "profile_service_name" {
  type    = string
  default = "profile-service"
}
