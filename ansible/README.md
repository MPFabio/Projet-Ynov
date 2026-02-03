# Ansible

Playbooks et inventaire pour Projet-Ynov (ModulOps test).

## Fichiers

- **inventory/gcp.yml** — Inventaire (à adapter avec les IP GKE ou dynamic inventory GCP)
- **playbooks/deploy-app.yml** — Déploiement app (kubectl / k8s)
- **playbooks/configure-nodes.yml** — Config de base des nœuds (SSH)

## Prérequis

- Ansible >= 2.10
- Pour deploy-app : `kubernetes.core` (`ansible-galaxy collection install kubernetes.core`)
- kubectl configuré vers le cluster GKE

## Usage

```bash
# Config nœuds (si inventaire rempli)
ansible-playbook playbooks/configure-nodes.yml

# Déploiement k8s : en pratique, depuis la racine du repo
kubectl apply -f k8s/
```

## Inventaire dynamique GCP (optionnel)

Pour découvrir les nœuds GKE automatiquement :

```bash
ansible-galaxy collection install google.cloud
# Puis configurer un inventory plugin gcp_compute
```
