/*
resource "google_clouddeploy_delivery_pipeline" "primary" {
  location = var.region
  name     = "pipeline"

  annotations = {
    my_first_annotation = "example-annotation-1"

    my_second_annotation = "example-annotation-2"
  }

  description = "basic description"

  labels = {
    my_first_label = "example-label-1"

    my_second_label = "example-label-2"
  }

  project = var.project_id

  serial_pipeline {
    stages {
      profiles  = ["dev"]
      target_id = google_clouddeploy_target.dev_env.id
    }
  }
  provider = google-beta
}

resource "google_clouddeploy_target" "dev_env" {
  location = var.region
  name     = "target"

  annotations = {
    my_first_annotation = "example-annotation-1"

    my_second_annotation = "example-annotation-2"
  }

  description = "basic description"

  execution_configs {
    usages            = ["RENDER", "DEPLOY"]
    execution_timeout = "3600s"
  }

  labels = {
    my_first_label = "example-label-1"

    my_second_label = "example-label-2"
  }

  project          = var.project_id
  require_approval = false

  run {
    location = "projects/${var.project_id}/locations/${var.region}"
  }
  provider = google-beta
}
*/
