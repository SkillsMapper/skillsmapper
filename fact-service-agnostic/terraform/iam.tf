resource "google_service_account" "gke_service_account" {
  account_id = "${google_container_cluster.cluster.name}-sa"
}

resource "google_project_iam_binding" "service-account-cloudsql-binding" {
  members = ["serviceAccount:${google_service_account.gke_service_account.email}"]
  role    = "roles/cloudsql.client"
  project = var.project_id
}

resource "google_project_iam_binding" "service-account-logging-binding" {
  members = ["serviceAccount:${google_service_account.gke_service_account.email}"]
  role    = "roles/logging.logWriter"
  project = var.project_id
}

resource "google_service_account_iam_binding" "service-account-workload-identity-binding" {
  service_account_id = google_service_account.gke_service_account.name
  members            = ["serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_sa}]"]
  role               = "roles/iam.workloadIdentityUser"
}
