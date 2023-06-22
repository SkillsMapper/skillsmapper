variable "project_id" {
  type        = string
  description = "The ID of the Google Cloud project to use."
}

variable "github_repo" {
  type = string
}

variable "container_repo" {
  type = string
}

variable "region" {
  type        = string
  description = "The region in which to create the resources."
}

variable "dev_project_id" {
  type        = string
  description = "The ID of the development project."
}

variable "app_installation_id" {
  type = string
}

variable "service_names" {
  description = "List of service names"
  type        = list(string)
}

variable "github_token" {
  description = "GitHub token"
  type        = string
  sensitive   = true
}

variable "profile_database_name" {
  type = string
}

variable "fact_database_user" {
  type        = string
}
variable "fact_database_name" {
  type        = string
}
variable "fact_database_instance" {
  type        = string
}
variable "fact_changed_topic" {
  type        = string
}
