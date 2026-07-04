variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "instance_name" {
  description = "Cloud SQL instance name"
  type        = string
  default     = "food-ordering-postgres"
}

variable "tier" {
  description = "Cloud SQL machine tier"
  type        = string
  default     = "db-custom-2-7680"
}

variable "network_self_link" {
  description = "Self-link of the VPC network for private IP"
  type        = string
}

variable "private_vpc_connection_id" {
  description = "ID of the private VPC connection (ensures ordering)"
  type        = string
}
