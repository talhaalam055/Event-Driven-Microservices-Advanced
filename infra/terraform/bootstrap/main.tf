# Creates the GCS bucket used as the Terraform remote state backend for infra/terraform/prod.
# Run this ONCE before the first `terraform init` in infra/terraform/prod:
#
#   cd infra/terraform/bootstrap
#   terraform init
#   terraform apply -var="project_id=YOUR_PROJECT_ID"
#
# Uses local state — acceptable because the only resource is the state bucket itself.
# After the bucket exists, all prod state is stored remotely.

terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

resource "google_storage_bucket" "terraform_state" {
  name                        = "${var.project_id}-terraform-state"
  location                    = var.region
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  # Keep only the 5 most recent state versions to control storage costs
  lifecycle_rule {
    condition {
      num_newer_versions = 5
    }
    action {
      type = "Delete"
    }
  }
}

output "state_bucket" {
  description = "Pass this as -backend-config=\"bucket=...\" when running terraform init in infra/terraform/prod"
  value       = google_storage_bucket.terraform_state.name
}
