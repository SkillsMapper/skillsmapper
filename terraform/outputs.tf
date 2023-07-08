output "public-ip" {
  value = module.environment.public-ip
}

output "public-domain" {
  value = module.environment.public-domain
}

output "management-project" {
  value = google_project.management_project.project_id
}

output "development-project" {
  value = google_project.dev_project.project_id
}

output "git-commit" {
  value = module.environment.git-commit
}
