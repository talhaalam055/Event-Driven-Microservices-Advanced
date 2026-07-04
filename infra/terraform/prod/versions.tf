terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Bucket name is passed via -backend-config at init time (see terraform.yml and
  # GCP-IMPLEMENTATION.md). The bucket itself is created by infra/terraform/bootstrap.
  backend "gcs" {
    prefix = "food-ordering/prod"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
