/*
resource "google_project_service" "identitytoolkit" {
  project = data.google_project.project.project_id
  service = "identitytoolkit.googleapis.com"
}

resource "google_identity_platform_config" "default" {
  project = data.google_project.project.project_id
  autodelete_anonymous_users = true
}
*/
