variable "project_id" {
  type = string
}

variable "region" {
  default = "us-central1"
  type    = string
}

variable "bucket_name" {
  type    = string
  default = "tags"
}

variable "tags_file_name" {
  type    = string
  default = "tags.json"
}
