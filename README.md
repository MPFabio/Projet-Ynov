# Projet-Ynov

Repo de test pour **ModulOps** : Terraform (GCP / GKE), Ansible et Kubernetes.

## Structure

| Dossier      | Contenu |
|-------------|---------|
| **terraform/** | Infra GCP : VPC, subnet, cluster GKE, node pool avec autoscaling |
| **ansible/**   | Playbooks (deploy-app, configure-nodes), inventaire, ansible.cfg |
| **k8s/**       | Manifests : namespace, ConfigMap, Deployment (nginx), Service |

## Prérequis

- Terraform >= 1.0
- Ansible >= 2.10
- kubectl
- Compte GCP et `gcloud` configuré

## Usage rapide

1. **Terraform** — Créer l’infra GCP / GKE  
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars  # éditer project_id
   terraform init && terraform plan && terraform apply
   gcloud container clusters get-credentials projet-ynov-gke --region europe-west1 --project VOTRE_PROJECT_ID
   ```

2. **Kubernetes** — Déployer l’app de test  
   ```bash
   kubectl apply -f k8s/
   kubectl get all -n projet-ynov
   ```

3. **Ansible** — Config nœuds ou déploiement (voir `ansible/README.md`).

## Lien avec ModulOps

- **Module Terraform** : importer le tfstate ou configurer une source GCS.
- **Module Kubernetes** : enregistrer le cluster GKE et gérer les ressources.
- **Module Ansible** : lancer les playbooks (configure-nodes, etc.).

Voir les README dans chaque sous-dossier pour le détail.
