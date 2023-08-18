output "public-ip" {
  value = module.application.public-ip
}

output "public-domain" {
  value = module.application.public-domain
}

output "management-project" {
  value = google_project.management_project.project_id
}

output "application-project" {
  value = google_project.application_project.project_id
}

output "git-commit" {
  value = module.application.git-commit
}
