# Workload Identity Federation — lets GitHub Actions authenticate to GCP without a JSON key

resource "google_service_account" "github_actions_sa" {
  account_id   = "github-actions-sa"
  display_name = "GitHub Actions Service Account"
  project      = var.project_id
}

# Least-privilege roles — replaces the previous overly broad roles/editor binding.
# Each role covers exactly what Terraform needs to provision or what CI/CD needs to run.
locals {
  github_sa_roles = toset([
    "roles/container.admin",                  # GKE clusters, node pools, credentials
    "roles/compute.networkAdmin",             # VPC, subnets, routes, Cloud NAT, firewall
    "roles/servicenetworking.networksAdmin",  # private service access (Cloud SQL VPC peering)
    "roles/sqladmin.admin",                   # Cloud SQL instances, databases, users
    "roles/artifactregistry.admin",           # repositories and their IAM bindings
    "roles/secretmanager.admin",              # secrets, versions, and access policies
    "roles/iam.serviceAccountAdmin",          # create and manage service accounts
    "roles/iam.serviceAccountUser",           # attach service accounts to GCP resources
    "roles/iam.workloadIdentityPoolAdmin",    # WIF pools and OIDC providers
    "roles/resourcemanager.projectIamAdmin",  # grant roles to other service accounts
    "roles/storage.admin",                    # Terraform remote state bucket
  ])
}

resource "google_project_iam_member" "github_sa_roles" {
  for_each = local.github_sa_roles
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions Pool"
  project                   = var.project_id
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  project                            = var.project_id

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  attribute_condition = "assertion.repository == '${var.github_repo}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "github_wif_binding" {
  service_account_id = google_service_account.github_actions_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repo}"
}

# ---------------------------------------------------------------------------
# CI/CD config secrets — workflows fetch these after authenticating via WIF.
# Non-sensitive identifiers (WIF_PROVIDER, WIF_SERVICE_ACCOUNT, GCP_PROJECT_ID)
# are stored as GitHub Actions Variables (vars.*), not here.
# ---------------------------------------------------------------------------

resource "google_secret_manager_secret" "ci_registry_url" {
  secret_id = "ci-registry-url"
  project   = var.project_id
  replication { auto {} }
}

resource "google_secret_manager_secret_version" "ci_registry_url" {
  secret      = google_secret_manager_secret.ci_registry_url.id
  secret_data = module.artifact_registry.repository_url
}

resource "google_secret_manager_secret" "ci_gke_cluster_name" {
  secret_id = "ci-gke-cluster-name"
  project   = var.project_id
  replication { auto {} }
}

resource "google_secret_manager_secret_version" "ci_gke_cluster_name" {
  secret      = google_secret_manager_secret.ci_gke_cluster_name.id
  secret_data = module.gke.cluster_name
}

resource "google_secret_manager_secret" "ci_cloudsql_connection_name" {
  secret_id = "ci-cloudsql-connection-name"
  project   = var.project_id
  replication { auto {} }
}

resource "google_secret_manager_secret_version" "ci_cloudsql_connection_name" {
  secret      = google_secret_manager_secret.ci_cloudsql_connection_name.id
  secret_data = module.cloudsql.instance_connection_name
}

resource "google_secret_manager_secret" "ci_cloudsql_proxy_sa" {
  secret_id = "ci-cloudsql-proxy-sa"
  project   = var.project_id
  replication { auto {} }
}

resource "google_secret_manager_secret_version" "ci_cloudsql_proxy_sa" {
  secret      = google_secret_manager_secret.ci_cloudsql_proxy_sa.id
  secret_data = module.cloudsql.cloudsql_proxy_sa_email
}

# GitHub token used by ArgoCD to pull from a private repository.
# The secret version (the actual token) must be created manually once:
#   echo -n "ghp_YOUR_TOKEN" | gcloud secrets versions add ci-github-token --data-file=-
# Generate a fine-grained PAT with Contents: read-only scope for this repo.
resource "google_secret_manager_secret" "ci_github_token" {
  secret_id = "ci-github-token"
  project   = var.project_id
  replication { auto {} }
}
