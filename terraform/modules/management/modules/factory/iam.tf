data "google_project" "dev_project" {
  project_id = var.dev_project_id
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_artifact_registry_repository_iam_member" "member" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.repository.repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.dev_project.number}@serverless-robot-prod.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "dev_project_cloud_run_admin" {
  project = var.dev_project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "project_service_account_user" {
  project = var.dev_project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}


/*
resource "google_service_account" "factory_sa" {
  account_id   = "factory-sa"
  project      = var.project_id
  display_name = "Factory Service Account"
  description  = "Created by terraform"
}

data "google_iam_policy" "factory_sa_policy" {
  binding {
    role    = "roles/run.developer"
    members = [
      "serviceAccount:${google_service_account.factory_sa.email}",
    ]
  }

  binding {
    role    = "roles/iam.serviceAccountUser"
    members = [
      "serviceAccount:${google_service_account.factory_sa.email}",
    ]
  }

  binding {
    role    = "roles/clouddeploy.jobRunner"
    members = [
      "serviceAccount:${google_service_account.factory_sa.email}",
    ]
  }
}
*/
