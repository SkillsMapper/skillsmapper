resource "google_compute_global_address" "global_address" {
  name    = "${var.prefix}-ip"
  project = var.project_id
}

resource "google_compute_url_map" "url_map" {
  name            = "${var.prefix}-url-map"
  default_service = google_compute_backend_bucket.ui_backend_bucket.self_link

  path_matcher {
    name            = "api-path-matcher"
    default_service = google_compute_backend_service.api_backend.self_link

    path_rule {
      paths   = ["/api/*"]
      service = google_compute_backend_service.api_backend.self_link
    }
  }
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name       = "${var.prefix}-fw"
  target     = google_compute_target_https_proxy.https_proxy.self_link
  ip_address = google_compute_global_address.global_address.address
  port_range = "443"

  depends_on = [google_compute_target_https_proxy.https_proxy]
}

resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "${var.prefix}-https-proxy"
  url_map          = google_compute_url_map.url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_cert.self_link]
}

resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  project = var.project_id
  name    = "${var.prefix}-cert"
  managed {
    domains = [var.domain]
  }
}

resource "google_compute_backend_service" "api_backend" {
  name                  = "${var.prefix}-api-backend"
  load_balancing_scheme = "EXTERNAL"
  protocol              = "HTTP"
  timeout_sec           = 10
  port_name             = "http"
  enable_cdn            = false

  backend {
    group = google_compute_region_network_endpoint_group.api_gateway_serverless_neg.id
  }
}

resource "google_compute_backend_bucket" "ui_backend_bucket" {
  project     = var.project_id
  name        = "${var.prefix}-ui"
  bucket_name = "${var.prefix}-ui"
  enable_cdn  = false
}

resource "google_compute_region_network_endpoint_group" "api_gateway_serverless_neg" {
  provider              = google-beta
  name                  = "${var.prefix}-api-gateway-serverless-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  serverless_deployment {
    platform = "apigateway.googleapis.com"
    resource = google_api_gateway_gateway.api_gw.gateway_id
  }
}

output "public-ip" {
  value = google_compute_global_address.global_address.address
}

output "public-domain" {
  value = google_compute_managed_ssl_certificate.ssl_cert.managed[0].domains[0]
}

