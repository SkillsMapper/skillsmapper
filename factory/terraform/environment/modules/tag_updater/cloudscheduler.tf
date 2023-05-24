resource "google_cloud_scheduler_job" "job" {
  name             = var.job_name
  schedule         = "0 0 * * SUN"
  time_zone        = "GMT"
  attempt_deadline = "30s"

  retry_config {
    retry_count = 3
  }

  http_target {
    uri         = google_cloudfunctions2_function.tags_updater_function.service_config[0].uri
    http_method = "POST"
    oidc_token {
      service_account_email = google_service_account.gcf_invoker_sa.email
    }
  }

  depends_on = [
    google_project_service.cloudscheduler
  ]
}


