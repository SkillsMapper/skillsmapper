resource "google_monitoring_dashboard" "default" {
  project        = var.project_id
  dashboard_json = templatefile("${path.module}/dashboard.json.template", {
    SKILL_SERVICE_NAME = var.skill_service_name
    PROJECT_ID         = var.dev_project_id
    REGION             = var.region
  })
}
