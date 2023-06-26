resource "google_pubsub_topic" "fact_changed_topic" {
  project = var.project_id
  name    = var.fact_changed_topic
}

resource "google_pubsub_topic" "fact_changed_deadletter_topic" {
  project = var.project_id
  name    = "${var.fact_changed_topic}-deadletter"
}
