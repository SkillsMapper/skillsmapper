variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "instance_name" {
  type    = string
  default = "facts-instance"
}

variable "database_tier" {
  type    = string
  default = "db-f1-micro"
}

variable "disk_size" {
  type    = number
  default = 10
}

variable "database_name" {
  type    = string
  default = "facts"
}

variable "fact_service_user" {
  type    = string
  default = "fact_service_user"
}

variable "secret_name" {
  type    = string
  default = "fact_service_db_password"
}

variable "fact_service_service_account_name" {
  type    = string
  default = "fact-service-sa"
}

variable "fact_service_name" {
  type = string
}

variable "fact_service_version" {
  type = string
}

variable "fact_changed_topic" {
  type = string
}

variable "management_project_id" {
  type = string
}
