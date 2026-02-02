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
