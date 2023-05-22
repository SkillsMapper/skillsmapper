variable "project_id" {
  type        = string
  description = "The ID of the Google Cloud project to use."
}

variable "billing_account" {
  description = "The billing account ID to use with the project"
}

variable "project_name" {
  default = "skillsmapper-management"
}

variable "region" {
  default     = "us-central1"
  type        = string
  description = "The region in which to create the resources."
}

variable "monitored_project_id" {
  type        = string
  description = "The ID of the project to monitor."
}

variable "app_installation_id" {
  type = string
}
