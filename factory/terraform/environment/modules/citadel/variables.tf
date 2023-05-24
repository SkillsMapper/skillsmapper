variable "project_id" {
  type        = string
  description = "The ID of the Google Cloud project."
}

variable "domain" {
  type        = string
  description = "The domain to be used for services."
}

variable "api_name" {
  type        = string
  description = "The name of the API."
}

variable "region" {
  type        = string
  description = "The Google Cloud region in which resources will be provisioned."
}

variable "profile_service_name" {
  type        = string
  description = "The name of the profile service."
}

variable "fact_service_name" {
  type        = string
  description = "The name of the fact service."
}

variable "skill_service_name" {
  type        = string
  description = "The name of the skill service."
}

variable "prefix" {
  type        = string
  description = "Prefix for load balancer related names"
}

variable "fact_changed_subscription" {
  type = string
}
