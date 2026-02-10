variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "project_name" {
  description = "Nom du projet (préfixe des ressources)"
  type        = string
  default     = "projet-ynov"
}

variable "region" {
  description = "Région GCP"
  type        = string
  default     = "europe-west1"
}

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "subnet_cidr" {
  description = "CIDR du subnet"
  type        = string
  default     = "10.0.0.0/20"
}

variable "node_count" {
  description = "Nombre de nœuds par défaut"
  type        = number
  default     = 2
}

variable "node_max_count" {
  description = "Nombre max de nœuds (autoscaling)"
  type        = number
  default     = 5
}

variable "node_machine_type" {
  description = "Type de machine des nœuds"
  type        = string
  default     = "e2-medium"
}

variable "node_disk_size_gb" {
  description = "Taille disque nœuds (GB)"
  type        = number
  default     = 50
}

# Clé SSH pour Ansible / AWX (générée par Terraform, déployée sur les nœuds GCP)
variable "ssh_username" {
  description = "Utilisateur SSH utilisé par Ansible sur les nœuds"
  type        = string
  default     = "ansible"
}

variable "additional_ssh_public_keys" {
  description = "Clés SSH publiques additionnelles (format: user:ssh-rsa AAAA...). Concaténées aux métadonnées projet."
  type        = string
  default     = ""
}

variable "ssh_source_ranges" {
  description = "Plages CIDR autorisées pour SSH (port 22) vers les nœuds (ex: 0.0.0.0/0 en dev, ou sous-réseau GKE uniquement)."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
