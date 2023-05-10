
variable "project_id" {
  description = "Your GCP project ID"
  type        = string
}

variable "region" {
  description = "The region for the GCS bucket"
  type        = string
}

variable "prefix" {
  description = "The prefix for the GCS bucket"
  type        = string
}

variable "ui_source" {
  type    = string
  default = "../../user-interface/src/*"
}
