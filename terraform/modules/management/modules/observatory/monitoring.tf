//https://cloud.google.com/composer/docs/terraform-cross-project-monitoring
/*
resource "google_monitoring_monitored_project" "dev" {
  metrics_scope = join("", ["locations/global/metricsScopes/", var.dev_project_id])
  name          = var.dev_project_id
}
*/
