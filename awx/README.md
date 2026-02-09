# AWX (Projet-Ynov)

Déploiement d’**AWX** pour lancer les playbooks du dossier `ansible/` depuis l’interface web ou depuis Kura (module Ansible).

---

## Option recommandée (Windows, sans WSL) : AWX sur GKE

**Une seule commande** : le script installe le plugin GKE si besoin, déploie AWX sur ton cluster GKE, lance le tunnel et affiche le mot de passe.

### Prérequis

- **kubectl** installé
- **Google Cloud SDK (gcloud)** installé (le script installe le plugin `gke-gcloud-auth-plugin` si absent)
- Un cluster GKE configuré dans ta config kubectl (ex. `gke_kura-devops_europe-west1_projet-ynov-gke`)

### Installation (tout-en-un)

Dans **PowerShell**, depuis le dossier `awx/` :

```powershell
cd C:\Users\fabio\Documents\Projet-Ynov\awx
.\setup-awx-tout.ps1
```

Le script : installe le plugin GKE si besoin → déploie l’Operator et AWX sur GKE → affiche **admin** + mot de passe → lance le **port-forward** en arrière-plan. Ouvre **http://localhost:8052** et connecte-toi.

### Accès à l’interface

1. **Récupérer le mot de passe** (affiché à la fin du script, ou) :
   ```powershell
   kubectl get secret -n awx awx-admin-password -o jsonpath='{.data.password}' | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }; Write-Host ""
   ```

2. **Port-forward** (garder le terminal ouvert) :
   ```powershell
   kubectl port-forward -n awx svc/awx-service 8052:80
   ```

3. Ouvrir **http://localhost:8052** dans le navigateur. Utilisateur : **admin**, mot de passe : celui affiché.

**Alternative** : une fois le service en `LoadBalancer`, l’IP externe est donnée par `kubectl get svc -n awx awx-service`. Tu peux ouvrir cette IP dans le navigateur (ajouter l’URL dans les paramètres AWX si besoin pour le login).

---

## Autre option : awx-without-k8s (Docker, avec WSL ou Linux)

Si tu préfères **Docker sans Kubernetes** : le projet [awx-without-k8s](https://github.com/fitbeard/awx-without-k8s) utilise Ansible pour déployer AWX en conteneurs. Sur Windows, le playbook doit être lancé depuis **WSL** (Ansible ne tourne pas nativement sur Windows). Si WSL n’a pas le réseau sur ta machine, utilise l’option GKE ci-dessus.

- Script (dans WSL) : `./setup-awx-docker-wsl.sh`
- Dépannage WSL (DNS, réseau) : voir **`WSL-RESEAU.md`**

---

## Utilisation avec les playbooks Projet-Ynov

1. Dans AWX : **Projects** → créer un projet (source **Manual** ou **Git**).
2. **Inventories** → créer un inventaire (ex. GCP) et ajouter les hôtes.
3. **Job Templates** → créer un template (playbook `configure-nodes.yml` ou `deploy-app.yml`, inventaire, credentials si besoin).
4. Lancer les jobs depuis l’interface AWX ou depuis **Kura** en pointant l’ansible-service vers l’URL d’AWX (ex. `http://localhost:8052` ou l’IP du LoadBalancer).

---

## Références

- [AWX](https://github.com/ansible/awx) — projet officiel
- [AWX Operator](https://github.com/ansible/awx-operator) — déploiement sur Kubernetes
- [awx-without-k8s](https://github.com/fitbeard/awx-without-k8s) — déploiement Docker sans K8s
