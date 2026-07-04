variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "repository_name" {
  description = "Artifact Registry repository name"
  type        = string
  default     = "food-ordering"
}

variable "gke_sa_email" {
  description = "GKE node service account email — granted reader access"
  type        = string
}

variable "github_sa_email" {
  description = "GitHub Actions service account email — granted writer access"
  type        = string
}
