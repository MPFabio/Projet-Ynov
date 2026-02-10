# Scripts

## setup-gcp.sh / setup-gcp.ps1

Récupère le **project ID GCP** via la CLI et génère `terraform/terraform.tfvars`.

**Prérequis :** `gcloud` configuré (`gcloud auth login`, `gcloud config set project VOTRE_PROJECT_ID`).

**Usage :**

```bash
# Bash / Git Bash
./scripts/setup-gcp.sh
```

```powershell
# PowerShell
.\scripts\setup-gcp.ps1
```

Écrit `terraform/terraform.tfvars` avec le projet actuel. Ensuite : `cd terraform && terraform init && terraform plan`.

## get_ansible_ssh_key.py

Récupère la **clé privée SSH Ansible** générée par Terraform pour l’utiliser dans AWX (credential Machine) ou en local.

**Prérequis :** avoir fait `terraform apply` (la clé est créée dans `terraform/ssh-keys.tf`).

**Usage :**

```bash
# Depuis le fichier local (terraform/.ansible_ssh_private_key)
python scripts/get_ansible_ssh_key.py --source file

# Depuis GCP Secret Manager (pip install google-cloud-secret-manager + gcloud auth)
export GCP_PROJECT_ID=kura-devops
python scripts/get_ansible_ssh_key.py --source secret
```

La sortie est la clé privée : tu peux la coller dans AWX (Informations d’identification → Machine, champ Clé privée). Utilisateur SSH = **ansible** (voir `terraform/README.md`).
