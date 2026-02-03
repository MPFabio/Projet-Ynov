# Kubernetes - Manifests

Ressources à déployer sur le cluster GKE créé par Terraform.

## Fichiers

- **namespace.yaml** — Namespace `projet-ynov`
- **configmap.yaml** — Config (ENV, LOG_LEVEL, APP_NAME)
- **deployment.yaml** — Déploiement test (nginx:alpine, 2 replicas)
- **service.yaml** — Service ClusterIP sur le port 80

## Prérequis

- Cluster GKE opérationnel (`terraform apply` + `gcloud container clusters get-credentials ...`)
- kubectl configuré

## Usage

```bash
# Depuis la racine du repo
kubectl apply -f k8s/

# Vérifier
kubectl get all -n projet-ynov
```

## Tester avec ModulOps

1. Créer un projet "Ynov" dans ModulOps.
2. Uploader le tfstate (ou configurer une source GCS) dans le module Terraform.
3. Enregistrer le cluster GKE dans le module Kubernetes.
4. Déployer les manifests via le module K8s ou en local avec `kubectl apply -f k8s/`.
