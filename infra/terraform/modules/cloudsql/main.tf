resource "random_password" "db_password" {
  length  = 20
  special = false
}

resource "google_sql_database_instance" "postgres" {
  name             = var.instance_name
  project          = var.project_id
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier = var.tier

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.network_self_link
      enable_private_path_for_google_cloud_services = true
    }

    backup_configuration {
      enabled    = true
      start_time = "03:00"
      backup_retention_settings {
        retained_backups = 7
      }
    }

    database_flags {
      name  = "max_connections"
      value = "200"
    }
  }

  deletion_protection = false

  depends_on = [var.private_vpc_connection_id]
}

resource "google_sql_database" "schemas" {
  for_each = toset(["order", "payment", "restaurant", "customer"])

  name     = each.value
  instance = google_sql_database_instance.postgres.name
  project  = var.project_id
}

resource "google_sql_user" "app_user" {
  name     = "food_ordering_app"
  instance = google_sql_database_instance.postgres.name
  password = random_password.db_password.result
  project  = var.project_id
}

# Store credentials in Secret Manager
resource "google_secret_manager_secret" "db_username" {
  secret_id = "food-ordering-db-username"
  project   = var.project_id
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_username" {
  secret      = google_secret_manager_secret.db_username.id
  secret_data = google_sql_user.app_user.name
}

resource "google_secret_manager_secret" "db_password" {
  secret_id = "food-ordering-db-password"
  project   = var.project_id
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db_password.result
}

# Service account used by Cloud SQL Auth Proxy sidecar via Workload Identity
resource "google_service_account" "cloudsql_proxy_sa" {
  account_id   = "cloudsql-proxy-sa"
  display_name = "Cloud SQL Proxy Service Account"
  project      = var.project_id
}

resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloudsql_proxy_sa.email}"
}

resource "google_project_iam_member" "secretmanager_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloudsql_proxy_sa.email}"
}

# Bind each K8s service account to this GCP SA via Workload Identity
resource "google_service_account_iam_member" "workload_identity_bindings" {
  for_each = toset(["order-service", "payment-service", "restaurant-service", "customer-service"])

  service_account_id = google_service_account.cloudsql_proxy_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[app/${each.value}-sa]"
}
