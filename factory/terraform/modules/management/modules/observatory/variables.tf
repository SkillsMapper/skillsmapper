variable "project_id" {
  type        = string
  description = "The ID of the Google Cloud project."
}

variable "dev_project_id" {
  type = string
}

variable "fact_service_name" {
  default = "fact-service"
}
