resource "google_container_cluster" "cluster" {
  name     = "${var.project_id}-gke"
  location = var.region
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = ""
    services_ipv4_cidr_block = ""
  }
  network          = google_compute_network.vpc.name
  subnetwork       = google_compute_subnetwork.subnet.name
  enable_autopilot = true
}
