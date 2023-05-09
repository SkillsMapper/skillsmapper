terraform {
  required_version = ">= 0.12.0, < 2.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=4.63.1, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=2.3.0"
    }
  }
}
