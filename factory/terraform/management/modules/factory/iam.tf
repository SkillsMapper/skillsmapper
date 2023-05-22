resource "google_service_account" "factory_sa" {
  account_id   = "factory-sa"
  project      = var.project_id
  display_name = "Factory Service Account"
  description  = "Created by terraform"
}

data "google_iam_policy" "factory_sa_policy" {
  binding {
    role = "roles/run.developer"
    members = [
      "serviceAccount:${google_service_account.factory_sa.email}",
    ]
  }

  binding {
    role = "roles/iam.serviceAccountUser"
    members = [
      "serviceAccount:${google_service_account.factory_sa.email}",
    ]
  }

  binding {
    role = "roles/clouddeploy.jobRunner"
    members = [
      "serviceAccount:${google_service_account.factory_sa.email}",
    ]
  }
}

resource "google_project_iam_policy" "project_iam_policy" {
  project     = var.project_id
  policy_data = data.google_iam_policy.factory_sa_policy.policy_data
}
