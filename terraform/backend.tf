terraform {
  backend "gcs" {
    bucket = "skillsmapper-management-2-tfstate"
    prefix = "terraform/state"
  }
}

