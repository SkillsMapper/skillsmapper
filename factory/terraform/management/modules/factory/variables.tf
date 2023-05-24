variable "project_id" {
  type        = string
  description = "The ID of the Google Cloud project."
}

variable "project_number" {
  type        = string
  description = "The number of the Google Cloud project."
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
