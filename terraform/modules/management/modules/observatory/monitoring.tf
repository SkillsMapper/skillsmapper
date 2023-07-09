resource "google_monitoring_monitored_project" "dev" {
  metrics_scope = var.project_id
  name          = var.dev_project_id
}
