# Terraform - Infra GCP / GKE

Déploie sur GCP :
- Un VPC et un subnet
- Un cluster GKE (Google Kubernetes Engine) avec node pool et autoscaling

## Prérequis

- Terraform >= 1.0
- Compte GCP et `gcloud` configuré
- `terraform login` ou `GOOGLE_APPLICATION_CREDENTIALS` pour le provider

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
# Éditer terraform.tfvars avec votre project_id GCP

terraform init
terraform plan
terraform apply
```

Récupérer les identifiants kubectl :

```bash
gcloud container clusters get-credentials projet-ynov-gke --region europe-west1 --project VOTRE_PROJECT_ID
```

## Backend (optionnel)

Pour stocker le state dans un bucket GCS :

```bash
cp backend.tf.example backend.tf
# Créer un bucket GCS et mettre son nom dans backend.tf
```
