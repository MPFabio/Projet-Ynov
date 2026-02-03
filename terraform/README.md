# Terraform - Cluster Kubernetes (GKE) sur GCP

Déploie sur GCP un **cluster Kubernetes managé (GKE)** :
- **VPC** + **subnet** (réseau dédié, plages pods/services pour GKE)
- **Cluster GKE** `projet-ynov-gke` (le cluster Kubernetes)
- **Node pool** avec autoscaling (nœuds du cluster)

## Prérequis

- Terraform >= 1.0
- Compte GCP et `gcloud` configuré
- `terraform login` ou `GOOGLE_APPLICATION_CREDENTIALS` pour le provider

## Usage

```bash
# terraform.tfvars est déjà configuré avec le projet kura-devops
# Sinon : cp terraform.tfvars.example terraform.tfvars

terraform init
terraform plan
terraform apply
```

Récupérer les identifiants kubectl :

```bash
gcloud container clusters get-credentials projet-ynov-gke --region europe-west1 --project kura-devops
```

## Backend (optionnel)

Pour stocker le state dans un bucket GCS :

```bash
cp backend.tf.example backend.tf
# Créer un bucket GCS et mettre son nom dans backend.tf
```
