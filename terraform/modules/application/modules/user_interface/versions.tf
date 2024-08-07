terraform {
  required_version = ">= 0.12.0, < 2.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=4.63.1, < 5.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">=2.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.1"
    }
  }
}
