resource "google_compute_network" "vpc_network" {
  name                    = "vpc-network"
  auto_create_subnetworks = false
  depends_on = [google_project_service.compute_engine]
}

resource "google_compute_subnetwork" "private_subnet" {
  name          = "private-subnet"
  region        = var.region
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.vpc_network.self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_subnetwork.private_subnet.name]
}
