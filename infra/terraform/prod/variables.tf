variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "food-ordering-cluster"
}

variable "github_repo" {
  description = "GitHub repo in owner/name format (e.g. acme/food-ordering)"
  type        = string
}
