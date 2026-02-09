#!/usr/bin/env bash
# Génère terraform/terraform.tfvars avec le project ID GCP actuel (gcloud config).
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TFVARS="$REPO_ROOT/terraform/terraform.tfvars"

if ! command -v gcloud &>/dev/null; then
  echo "gcloud non trouvé. Installez le Google Cloud SDK."
  exit 1
fi

PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" = "(unset)" ]; then
  echo "Aucun projet GCP configuré. Lancez: gcloud config set project VOTRE_PROJECT_ID"
  exit 1
fi

echo "Project ID GCP: $PROJECT_ID"
cat > "$TFVARS" << EOF
project_id     = "$PROJECT_ID"
project_name   = "projet-ynov"
region         = "europe-west1"
environment    = "dev"
node_count     = 2
node_max_count = 5
EOF
echo "Écrit: $TFVARS"
echo "Vous pouvez lancer: cd terraform && terraform init && terraform plan"
