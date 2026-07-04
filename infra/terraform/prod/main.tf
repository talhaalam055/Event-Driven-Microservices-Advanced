module "network" {
  source = "../modules/network"

  project_id   = var.project_id
  region       = var.region
  network_name = "food-ordering-vpc"
}

module "gke" {
  source = "../modules/gke"

  project_id     = var.project_id
  region         = var.region
  cluster_name   = var.cluster_name
  network_name   = module.network.network_name
  subnet_name    = module.network.subnet_name
  machine_type   = "e2-standard-4"
  node_count     = 3
  min_node_count = 2
  max_node_count = 5
}

module "cloudsql" {
  source = "../modules/cloudsql"

  project_id                = var.project_id
  region                    = var.region
  instance_name             = "food-ordering-postgres"
  tier                      = "db-custom-2-7680"
  network_self_link         = module.network.network_self_link
  private_vpc_connection_id = module.network.subnet_self_link
}

module "artifact_registry" {
  source = "../modules/artifact-registry"

  project_id      = var.project_id
  region          = var.region
  repository_name = "food-ordering"
  gke_sa_email    = module.gke.gke_sa_email
  github_sa_email = google_service_account.github_actions_sa.email
}
