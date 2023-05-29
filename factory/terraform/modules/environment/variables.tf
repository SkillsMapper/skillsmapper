variable "project_id" {
  type        = string
  description = "The ID of the Google Cloud project to use."
}

variable "project_name" {
  type        = string
}

variable "region" {
  type        = string
  description = "The region in which to create the resources."
}

variable "tag_bucket_name" {
  type        = string
  default     = "tags"
  description = "The name to give to the Google Cloud Storage bucket."
}

variable "tags_file_name" {
  type        = string
  default     = "tags.csv"
  description = "The name of the file to store tags in."
}

variable "fact_changed_topic" {
  type        = string
  default     = "fact-changed"
  description = "The name of the Pub/Sub topic for changed facts notifications."
}

variable "prefix" {
  type        = string
  description = "A prefix to apply to all resource names."
}

variable "skill_service_name" {
  type        = string
  description = "The name of the skill service."
}

variable "fact_service_name" {
  type        = string
  description = "The name of the fact service."
}

variable "profile_service_name" {
  type        = string
  description = "The name of the profile service."
}

variable "domain" {
  description = "The domain where the project will be hosted."
  type        = string
}

variable "fact_changed_subscription" {
  type    = string
  default = "fact-changed-subscription"
}

variable "api_key" {
  description = "The API key for Identity Platform"
  type        = string
}

variable "management_project_id" {
  type = string
}

variable "skill_service_version" {
  type = string
}

variable "profile_service_version" {
  type = string
}

variable "fact_service_version" {
  type = string
}

variable "container_repo" {
  type = string
}
