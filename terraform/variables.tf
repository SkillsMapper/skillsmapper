variable "management_project_id" {
  type        = string
  description = "The ID of the Google Cloud project to use."
}

variable "management_project_name" {
  default = "SkillsMapper Management"
  type    = string
}

variable "application_project_id" {
  type = string
}

variable "application_project_name" {
  default = "SkillsMapper Development"
  type    = string
}

variable "github_repo" {
  type = string
}

variable "github_token" {
  description = "GitHub token"
  type        = string
  sensitive   = true
}

variable "container_repo" {
  default = "skillsmapper"
  type    = string
}

variable "region" {
  default     = "us-west2"
  type        = string
  description = "The region in which to create the resources."
}

variable "app_installation_id" {
  type = string
}

variable "service_names" {
  description = "List of service names"
  type        = list(string)
  default     = ["skill-service", "fact-service", "profile-service"]
}

variable "prefix" {
  default = "skillsmapper"
  type    = string
}

variable "domain" {
  description = "The domain where the project will be hosted."
  type        = string
}

variable "api_key" {
  description = "The API key for Identity Platform"
  type        = string
}

variable "billing_account" {
  description = "The billing account ID to use with the project"
  type        = string
}

variable "skill_service_name" {
  type        = string
  default     = "skill-service"
  description = "The name of the skill service."
}

variable "skill_service_dev_version" {
  type    = string
  default = "latest"
}

variable "fact_service_dev_version" {
  type    = string
  default = "latest"
}

variable "profile_service_dev_version" {
  type    = string
  default = "latest"
}

variable "fact_service_name" {
  type        = string
  default     = "fact-service"
  description = "The name of the fact service."
}

variable "profile_service_name" {
  type        = string
  default     = "profile-service"
  description = "The name of the profile service."
}

variable "profile_database_name" {
  type        = string
  default     = "(default)"
  description = "The name of the profile FireStore database."
}

variable "fact_database_user" {
  default = "fact_service_user"
  type    = string
}
variable "fact_database_name" {
  default = "facts"
  type    = string
}
variable "fact_database_instance" {
  default = "facts-instance"
  type    = string
}
variable "fact_changed_topic" {
  default = "fact-changed"
  type    = string
}

variable "cloudbuild_connection_name" {
  default = "skillsmapper-github-connection"
  type    = string
}
