# Terraform - Cluster Kubernetes (GKE) sur GCP

Déploie sur GCP un **cluster Kubernetes managé (GKE)** :
- **VPC** + **subnet** (réseau dédié, plages pods/services pour GKE)
- **Cluster GKE** `projet-ynov-gke` (le cluster Kubernetes)
- **Node pool** avec autoscaling (nœuds du cluster)
- **Clé SSH Ansible** : générée par Terraform, clé publique injectée dans les métadonnées du projet (tous les nœuds/VM l’acceptent), clé privée en fichier local + Secret Manager pour récupération dynamique (voir ci‑dessous).

## Prérequis

- Terraform >= 1.0
- Compte GCP et `gcloud` configuré
- `terraform login` ou `GOOGLE_APPLICATION_CREDENTIALS` pour le provider

### Activer les APIs GCP (une fois par projet)

Terraform ne les active pas (nécessite le rôle Service Usage Admin). À faire une fois :

```bash
# Remplacer MY_PROJECT_ID par l'ID du projet GCP
gcloud services enable compute.googleapis.com container.googleapis.com secretmanager.googleapis.com --project=MY_PROJECT_ID
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

## Backend GCS (tfstate)

Le state est stocké dans le bucket GCS **kura-ynov** (fichier `backend.tf`).

- **Prérequis** : le bucket doit exister ; le compte utilisé (gcloud ou `GOOGLE_APPLICATION_CREDENTIALS`) doit avoir les droits **Storage Object Admin** (ou **Storage Admin**) sur ce bucket.
- Au premier `terraform init`, Terraform crée l’objet state sous le préfixe `projet-ynov/terraform/state`.

Pour utiliser un autre bucket, adapter `backend.tf` (ou s’inspirer de `backend.tf.example`).

## Clé SSH Ansible (AWX / nœuds GCP)

Terraform génère une clé SSH (ED25519), injecte la **clé publique** dans les métadonnées du projet GCP (toutes les VM/nœuds du projet l’acceptent) et garde la **clé privée** :

- Dans un **fichier local** : `terraform/.ansible_ssh_private_key` (ignoré par Git). Utilisateur SSH = `ansible` (variable `ssh_username` si tu changes).
- Dans **GCP Secret Manager** (secret `ansible-ssh-private-key`) pour la récupérer dynamiquement.

### Récupérer la clé pour la credential AWX

1. **Depuis le fichier** (après `terraform apply`) :
   ```bash
   python scripts/get_ansible_ssh_key.py --source file
   ```
2. **Depuis Secret Manager** (nécessite `gcloud auth` et `pip install google-cloud-secret-manager`) :
   ```bash
   export GCP_PROJECT_ID=kura-devops   # ou ton project_id
   python scripts/get_ansible_ssh_key.py --source secret
   ```
   Copie la sortie et colle-la dans AWX : **Ressources** → **Informations d'identification** → **Ajouter** → type **Machine** → Nom d’utilisateur **ansible**, Clé privée = la sortie du script. Puis associe cette credential au Job Template.
