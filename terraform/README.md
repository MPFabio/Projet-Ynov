# Terraform - Cluster Kubernetes (GKE) sur GCP

Déploie sur GCP un **cluster Kubernetes managé (GKE)** :
- **VPC** + **subnet** (réseau dédié, plages pods/services pour GKE)
- **Cluster GKE** `projet-ynov-gke` (le cluster Kubernetes)
- **Node pool** avec autoscaling (nœuds du cluster)

## Prérequis

- Terraform >= 1.0
- Compte GCP et `gcloud` configuré
- `terraform login` ou `GOOGLE_APPLICATION_CREDENTIALS` pour le provider

### Activer les APIs GCP (une fois par projet)

Terraform ne les active pas (nécessite le rôle Service Usage Admin). À faire une fois :

```bash
# Remplacer MY_PROJECT_ID par l'ID du projet GCP
gcloud services enable compute.googleapis.com container.googleapis.com --project=MY_PROJECT_ID
```

Ou dans la console : [APIs & Services → Library](https://console.cloud.google.com/apis/library) → activer **Compute Engine API** et **Kubernetes Engine API**.

### Compte de service pour la CI (GitHub Actions)

Le secret `GCP_SA_KEY` doit être une clé JSON d’un compte de service ayant au minimum :

- **Compute Admin** (roles/compute.admin)
- **Kubernetes Engine Admin** (roles/container.admin)
- **Service Account User** (roles/iam.serviceAccountUser) si besoin

Dans IAM : ajouter le compte de service au projet et lui attribuer ces rôles.

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
