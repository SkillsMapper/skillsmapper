variable "project_id" {}

variable "database_name" {
  default = "facts"
}

variable "database_username" {
  default = "user"
}

variable "database_password" {}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-c"
}

variable "database_tier" {
  default = "db-f1-micro"
}

variable "database_disk_size" {
  default = 10
}

variable "local_ip_range" {
  default = "82.71.37.92/32"
}

variable "k8s_namespace" {
  default = "facts"
}

variable "k8s_sa" {
  default = "facts-sa"
}
