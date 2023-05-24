resource "google_api_gateway_api" "api_gw" {
  provider = google-beta
  project  = var.project_id
  api_id   = "${var.api_name}-api-gw"
  depends_on = [
    google_project_service.apigateway,
    google_project_service.servicecontrol
  ]
}

resource "google_api_gateway_api_config" "api_gw_config" {
  provider      = google-beta
  project       = var.project_id
  api           = google_api_gateway_api.api_gw.api_id
  api_config_id = "${var.api_name}-api-gw-config"

  gateway_config {
    backend_config {
      google_service_account = google_service_account.gateway.id
    }
  }

  openapi_documents {
    document {
      path = "spec.yaml"
      contents = base64encode(templatefile("../../../user-interface/api.yaml.template",
        {
          API_NAME            = var.api_name
          DOMAIN              = var.domain
          PROJECT_ID          = var.project_id
          SKILL_SERVICE_URL   = data.google_cloud_run_service.skill_service.status[0].url
          FACT_SERVICE_URL    = data.google_cloud_run_service.fact_service.status[0].url
          PROFILE_SERVICE_URL = data.google_cloud_run_service.profile_service.status[0].url
        }
      ))
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_api_gateway_gateway" "api_gw" {
  provider   = google-beta
  api_config = google_api_gateway_api_config.api_gw_config.id
  gateway_id = "${var.api_name}-gateway"
  project    = var.project_id
  region     = var.region
}

output "gateway-hostname" {
  value = google_api_gateway_gateway.api_gw.default_hostname
}
