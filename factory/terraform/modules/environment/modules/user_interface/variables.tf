variable "project_id" {
  description = "Your GCP project ID"
  type        = string
}

variable "region" {
  description = "The region for the GCS bucket"
  type        = string
}

variable "ui_project" {
  description = "The project for the UI"
  type        = string
  default     = "../../user-interface"
}

variable "ui_source" {
  description = "The source code for the UI"
  type        = string
  default     = "../../user-interface/src/*"
}

variable "api_key" {
  description = "The API key for Identity Platform"
  type        = string
}
