resource "google_compute_global_address" "global_address" {
  name    = "${var.prefix}-ip"
  project = var.project_id
}

resource "google_compute_url_map" "url_map" {
  name            = "${var.prefix}-url-map"
  default_service = google_compute_backend_bucket.ui_backend_bucket.name

  host_rule {
    hosts        = [var.domain]
    path_matcher = "${var.prefix}-api-path-matcher"
  }

    path_matcher {
    name            = "${var.prefix}-api-path-matcher"
    default_service = google_compute_backend_bucket.ui_backend_bucket.id

    path_rule {
      paths   = ["/api/*"]
      service = google_compute_backend_service.api_backend.id
    }
  }
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name       = "${var.prefix}-fw"
  project    = var.project_id
  target     = google_compute_target_https_proxy.https_proxy.self_link
  ip_address = google_compute_global_address.global_address.address
  port_range = "443"

  depends_on = [google_compute_target_https_proxy.https_proxy]
}

resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "${var.prefix}-https-proxy"
  project          = var.project_id
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
  project               = var.project_id
  name                  = "${var.prefix}-api-backend"
  load_balancing_scheme = "EXTERNAL"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 30
  enable_cdn            = false

  backend {
    group = google_compute_region_network_endpoint_group.api_gateway_serverless_neg.id
  }
}

resource "google_compute_backend_bucket" "ui_backend_bucket" {
  project     = var.project_id
  name        = "${var.project_id}-ui"
  bucket_name = "${var.project_id}-ui"
  enable_cdn  = false
}

resource "google_compute_region_network_endpoint_group" "api_gateway_serverless_neg" {
  provider              = google-beta
  project               = var.project_id
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

