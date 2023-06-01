resource "google_identity_platform_config" "default" {
  project                    = var.project_id
  autodelete_anonymous_users = true
}

resource "google_identity_platform_project_default_config" "default" {
  sign_in {
    allow_duplicate_emails = false

    email {
      enabled           = true
      password_required = false
    }
  }
}
