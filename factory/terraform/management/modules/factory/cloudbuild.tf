resource "google_secret_manager_secret" "github-token-secret" {
  depends_on = [google_project_service.secret_manager]
  provider   = google-beta
  secret_id  = "github-token-secret"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "github-token-secret-version" {
  provider    = google-beta
  secret      = google_secret_manager_secret.github-token-secret.id
  secret_data = file("github-token.txt")
}

data "google_iam_policy" "p4sa-secretAccessor" {
  provider = google-beta
  binding {
    role = "roles/secretmanager.secretAccessor"
    members = [
      "serviceAccount:${var.project_number}@cloudbuild.gserviceaccount.com",
      "serviceAccount:service-${var.project_number}@gcp-sa-cloudbuild.iam.gserviceaccount.com",
      "serviceAccount:${google_service_account.factory_sa.email}"
    ]
  }
}

resource "google_secret_manager_secret_iam_policy" "policy" {
  depends_on  = [google_project_service.cloudbuild]
  provider    = google-beta
  secret_id   = google_secret_manager_secret.github-token-secret.secret_id
  policy_data = data.google_iam_policy.p4sa-secretAccessor.policy_data
}

resource "google_cloudbuildv2_connection" "skillsmapper-github-conn" {
  depends_on = [google_project_service.cloudbuild]
  provider   = google-beta
  location   = var.region
  name       = "skillsmapper-github-conn"

  github_config {
    app_installation_id = var.app_installation_id
    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.github-token-secret-version.id
    }
  }
}

resource "google_cloudbuildv2_repository" "skillsmapper-repo" {
  provider          = google-beta
  #location          = var.region
  name              = "skillsmapper-repo"
  parent_connection = google_cloudbuildv2_connection.skillsmapper-github-conn.name
  remote_uri        = var.github_repo
}

//https://discuss.hashicorp.com/t/repository-mapping-does-not-exist-when-creating-google-cloudbuild-trigger-for-github-repo/35621/10

/*
resource "google_cloudbuild_trigger" "repo-trigger" {
  provider = google-beta
  location = var.region

  repository_event_config {
    repository = google_cloudbuildv2_repository.skillsmapper-repo.id
    push {
      branch = "feature-.*"
    }
  }

  filename = "cloudbuild.yaml"
}
*/
