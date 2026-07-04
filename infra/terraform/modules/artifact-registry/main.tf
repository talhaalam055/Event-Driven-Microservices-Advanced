resource "google_artifact_registry_repository" "docker" {
  location      = var.region
  repository_id = var.repository_name
  description   = "Docker images for food ordering system"
  format        = "DOCKER"
  project       = var.project_id
}

resource "google_artifact_registry_repository_iam_member" "gke_reader" {
  project    = var.project_id
  location   = google_artifact_registry_repository.docker.location
  repository = google_artifact_registry_repository.docker.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${var.gke_sa_email}"
}

resource "google_artifact_registry_repository_iam_member" "github_writer" {
  project    = var.project_id
  location   = google_artifact_registry_repository.docker.location
  repository = google_artifact_registry_repository.docker.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${var.github_sa_email}"
}
