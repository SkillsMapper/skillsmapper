variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "bucket_name" {
  type    = string
  default = "tags"
}

variable "tags_file_name" {
  type    = string
  default = "tags.json"
}

variable "function_name" {
  type    = string
  default = "tag-updater"
}

variable "function_source_file_name" {
  type    = string
  default = "source.zip"
}

variable "function_source_file_source" {
  type    = string
  default = "../../tag-updater/source/source.zip"
}

variable "job_name" {
  type    = string
  default = "tag-updater-job"
}
