resource "google_monitoring_dashboard" "skill_service_dashboard" {
  project        = var.project_id
  dashboard_json = templatefile("${path.module}/dashboard.json.template", {
    SERVICE_NAME         = var.skill_service_name
    MONITORED_PROJECT_ID = var.dev_project_id
    REGION               = var.region
  })
}

resource "google_monitoring_dashboard" "fact_service_dashboard" {
  project        = var.project_id
  dashboard_json = templatefile("${path.module}/dashboard.json.template", {
    SERVICE_NAME         = var.fact_service_name
    MONITORED_PROJECT_ID = var.dev_project_id
    REGION               = var.region
  })
}

resource "google_monitoring_dashboard" "profile_service_dashboard" {
  project        = var.project_id
  dashboard_json = templatefile("${path.module}/dashboard.json.template", {
    SERVICE_NAME         = var.profile_service_name
    MONITORED_PROJECT_ID = var.dev_project_id
    REGION               = var.region
  })
}



