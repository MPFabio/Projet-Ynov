output "cluster_name" {
  description = "Nom du cluster GKE"
  value       = google_container_cluster.gke.name
}

output "cluster_endpoint" {
  description = "Endpoint du cluster"
  value       = google_container_cluster.gke.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Certificat CA du cluster"
  value       = google_container_cluster.gke.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "vpc_name" {
  description = "Nom du VPC"
  value       = google_compute_network.vpc.name
}

output "subnet_name" {
  description = "Nom du subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "region" {
  description = "Région utilisée"
  value       = var.region
}

output "project_id" {
  description = "Project ID GCP"
  value       = var.project_id
}

# Clé SSH Ansible (pour AWX / script get-ansible-ssh-key)
output "ansible_ssh_username" {
  description = "Utilisateur SSH à utiliser dans la credential Machine AWX"
  value       = var.ssh_username
}

output "ansible_ssh_private_key_path" {
  description = "Chemin du fichier contenant la clé privée (après terraform apply)"
  value       = local_file.ansible_private_key.filename
}

output "ansible_ssh_secret_name" {
  description = "Nom du secret Secret Manager pour récupérer la clé (script Python)"
  value       = google_secret_manager_secret.ansible_ssh_private_key.secret_id
}
