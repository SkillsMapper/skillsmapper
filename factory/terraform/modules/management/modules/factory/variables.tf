variable "project_id" {
  type        = string
  description = "The ID of the Google Cloud project."
}

variable "dev_project_id" {
  type = string
}

variable "region" {
  default     = "us-central1"
  type        = string
  description = "The region in which to create the resources."
}

variable "app_installation_id" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "container_repo" {
  type = string
}

variable "service_names" {
  description = "List of service names"
  type        = list(string)
}