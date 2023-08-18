output "public-ip" {
  value = module.citadel.public-ip
}

output "public-domain" {
  value = module.citadel.public-domain
}

output "git-commit" {
  value = data.external.git_commit.result.sha
}
