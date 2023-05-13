terraform {
  required_version = ">= 0.12.0, < 2.0.0"

  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">=4.63.1, < 5.0.0"
    }
  }
}
