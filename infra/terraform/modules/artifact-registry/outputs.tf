output "repository_url" {
  description = "Full URL prefix for pushing/pulling images"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_name}"
}

output "repository_name" {
  value = google_artifact_registry_repository.docker.name
}
