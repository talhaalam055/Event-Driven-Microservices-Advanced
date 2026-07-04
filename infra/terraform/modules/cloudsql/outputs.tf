output "instance_connection_name" {
  description = "Cloud SQL connection name used by Auth Proxy (PROJECT:REGION:INSTANCE)"
  value       = google_sql_database_instance.postgres.connection_name
}

output "instance_private_ip" {
  value = google_sql_database_instance.postgres.private_ip_address
}

output "cloudsql_proxy_sa_email" {
  value = google_service_account.cloudsql_proxy_sa.email
}

output "db_username_secret_id" {
  value = google_secret_manager_secret.db_username.secret_id
}

output "db_password_secret_id" {
  value = google_secret_manager_secret.db_password.secret_id
}
