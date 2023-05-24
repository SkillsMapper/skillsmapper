/*
resource "google_cloudbuild_trigger" "buildpacks_trigger" {
  provider = google
  project  = var.project_id
  name     = "buildpacks-trigger"
  filename = "cloudbuild.yaml"

  included_files = [
    "**",
  ]
}

resource "null_resource" "trigger_build" {
  provisioner "local-exec" {
    command = "gcloud builds submit --pack image=gcr.io/${var.project_id}/${var.image_name}:latest ."
  }

  triggers = {
    always_run = timestamp()
  }
}

output "cloudbuild_trigger_id" {
  value = google_cloudbuild_trigger.buildpacks_trigger.id
}
*/
