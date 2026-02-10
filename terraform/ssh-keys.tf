# Clé SSH générée par Terraform pour Ansible/AWX
# - Clé publique injectée dans les métadonnées du projet GCP (tous les nœuds/VM l'acceptent)
# - Clé privée écrite en local (gitignore) + stockée dans Secret Manager pour récupération dynamique

resource "tls_private_key" "ansible" {
  algorithm = "ED25519"
}

# Métadonnées projet : clé publique SSH (appliquée à toutes les VM/nœuds du projet)
resource "google_compute_project_metadata_item" "ssh_keys" {
  project = var.project_id
  key     = "ssh-keys"
  value   = trimspace("${var.ssh_username}:${tls_private_key.ansible.public_key_openssh}${var.additional_ssh_public_keys != "" ? "\n${var.additional_ssh_public_keys}" : ""}")
}

# Fichier local (pour usage manuel / backup) — ne pas committer (voir .gitignore)
resource "local_file" "ansible_private_key" {
  content         = tls_private_key.ansible.private_key_openssh
  filename        = "${path.module}/.ansible_ssh_private_key"
  file_permission = "0600"
}

# Secret Manager : API + secret pour récupérer la clé dynamiquement (script Python)
resource "google_project_service" "secretmanager" {
  project            = var.project_id
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_secret_manager_secret" "ansible_ssh_private_key" {
  project   = var.project_id
  secret_id = "ansible-ssh-private-key"
  replication {
    auto {}
  }
  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "ansible_ssh_private_key" {
  secret      = google_secret_manager_secret.ansible_ssh_private_key.id
  secret_data = tls_private_key.ansible.private_key_openssh
}

# Pare-feu : autoriser SSH (port 22) vers les nœuds / VM portant les tags du projet
resource "google_compute_firewall" "allow_ssh_ansible" {
  name    = "${var.project_name}-allow-ssh-ansible"
  network = google_compute_network.vpc.self_link

  direction = "INGRESS"
  priority  = 1000

  target_tags = ["gke-node", var.project_name]
  source_ranges = var.ssh_source_ranges

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  description = "Autorise SSH (22) depuis ssh_source_ranges vers les nœuds/VM taggés pour Ansible/AWX."
}
