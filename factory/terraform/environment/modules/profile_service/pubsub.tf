resource "google_pubsub_subscription" "subscription" {
  project              = var.project_id
  name                 = var.fact_changed_subscription
  topic                = var.fact_changed_topic
  ack_deadline_seconds = 20

  push_config {
    push_endpoint = "${google_cloud_run_service.profile_service.status[0].url}/factschanged"
    oidc_token {
      service_account_email = google_service_account.fact_changed_subscription_sa.email
      audience              = "${google_cloud_run_service.profile_service.status[0].url}/factschanged"
    }
  }

  dead_letter_policy {
    dead_letter_topic     = data.google_pubsub_topic.fact_changed_deadletter_topic.id
    max_delivery_attempts = 5
  }

  depends_on = [google_cloud_run_service.profile_service]
}

data "google_pubsub_topic" "fact_changed_deadletter_topic" {
  project = var.project_id
  name    = "${var.fact_changed_topic}-deadletter"
}
