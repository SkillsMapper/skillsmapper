resource "google_cloudfunctions2_function" "tags_updater_function" {
  name        = var.function_name
  location    = var.region
  description = "Tag Updater"

  build_config {
    runtime     = "go120"
    entry_point = var.function_name
    source {
      storage_source {
        bucket = google_storage_bucket.gcf_source_bucket.name
        object = google_storage_bucket_object.tag_updater_source.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
    environment_variables = {
      PROJECT_ID  = var.project_id
      BUCKET_NAME = google_storage_bucket.tags_bucket.name
      OBJECT_NAME : var.tags_file_name
    }
    service_account_email = google_service_account.gcf_sa.email
  }

  depends_on = [
    google_project_service.cloudfunctions,
    google_project_service.cloudbuild,
    google_project_service.artifactregistry,
    google_project_service.run,
  ]
}

output "function_uri" {
  value = google_cloudfunctions2_function.tags_updater_function.service_config[0].uri
}
