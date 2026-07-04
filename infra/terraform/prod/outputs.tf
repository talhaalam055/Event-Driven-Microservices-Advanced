output "cluster_name" {
  value = module.gke.cluster_name
}

output "registry_url" {
  description = "Prefix for image names: registry_url/service-name:tag"
  value       = module.artifact_registry.repository_url
}

output "cloudsql_connection_name" {
  description = "Pass this to --cloud-sql-proxy arg and Helm values"
  value       = module.cloudsql.instance_connection_name
}

output "wif_provider" {
  description = "Set as WIF_PROVIDER secret in GitHub"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "github_sa_email" {
  description = "Set as WIF_SERVICE_ACCOUNT secret in GitHub"
  value       = google_service_account.github_actions_sa.email
}
