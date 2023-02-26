variable "project_id" {}

variable "region" {
  default = "us-central1"
}

variable "bucket_name" {
  default = "tags"
}

variable "tags_file_name" {
  default = "tags.json"
}

variable "function_name" {
  default = "tag-updater"
}

variable "function_source_file_name" {
  default = "source.zip"
}

variable "function_source_file_source" {
  default = "../source/source.zip"
}
