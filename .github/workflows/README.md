# GitHub Actions

## CI - Validate (`validate.yml`)

- **Déclencheur** : push et pull_request sur `main`
- **Jobs** :
  - **Terraform** : `fmt -check`, `init -backend=false`, `validate`
  - **Kubernetes** : `kubectl apply --dry-run=client` sur tous les manifests `k8s/*.yaml`
  - **Ansible** : `ansible-playbook --syntax-check` sur les playbooks

Aucun secret requis.

## CD - Deploy (`deploy.yml`)

- **Déclencheur** : manuel (**Actions** → **CD - Deploy** → **Run workflow**)
- **Options** :
  - **Exécuter Terraform apply** : cocher pour appliquer l’infra GCP/GKE
  - **Exécuter kubectl apply** : cocher pour déployer les manifests k8s (décoché par défaut si seul Terraform est voulu)

### Secrets à configurer (Settings → Secrets and variables → Actions)

| Secret | Description |
|--------|-------------|
| `GCP_PROJECT_ID` | ID du projet GCP (ex. `kura-devops`) |
| `GCP_SA_KEY` | Contenu JSON du compte de service GCP (clé) |
| `TFSTATE_BUCKET` | (Optionnel) Nom du bucket GCS pour le state Terraform |

Sans ces secrets, le workflow CD ne peut pas s’exécuter correctement. Pour ce repo, configurer `GCP_PROJECT_ID` = `kura-devops`.
