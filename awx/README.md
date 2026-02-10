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

## Premiers pas dans l’interface AWX (jamais utilisé ?)

Oui, la première fois tu crées **à la main** dans l’interface : un **inventaire**, puis un **Job Template**. Ensuite tu peux lancer les jobs depuis AWX ou depuis Kura.

### 1. Vérifier le Projet

- Menu **Ressources** → **Projets**. Tu dois avoir un projet (ex. **Projet-Ynov**) avec l’URL Git et la branche `main`.
- Clique sur le projet → bouton **Actualiser** (↻) si besoin pour que AWX récupère les playbooks. Attends que le statut soit vert (succès).
- **Répertoire Playbook** : si ton formulaire de projet affiche ce champ, mets `ansible/playbooks`. Sinon, laisse vide et indique le **chemin complet** du playbook dans le Job Template (ex. `ansible/playbooks/configure-nodes.yml`).

### 2. Créer un inventaire

Un inventaire = la liste des machines sur lesquelles Ansible va jouer les playbooks.

- Menu **Ressources** → **Inventaires** → **Ajouter** → **Inventaire**.
- **Nom** : par ex. `GCP` ou `Mes serveurs`.
- **Organisation** : `Default`. Enregistrer.
- Ensuite, ouvre cet inventaire → onglet **Hôtes** → **Ajouter**.
  - Soit tu ajoutes des **hôtes à la main** : nom (ex. `node-1`), adresse (IP ou hostname). Tu peux en ajouter plusieurs.
  - Soit tu utilises un **script d’inventaire dynamique** (ex. `gcp_compute`) : dans ce cas tu crées d’abord une credential GCP et tu l’associes à l’inventaire (Source : « Inventaire géré par Ansible Tower » → Source : « Google Compute Engine », credential GCP). Pour débuter, 1–2 hôtes en manuel suffisent.

### 3. Créer un Job Template

C’est le « job » que tu lanceras (et que Kura pourra lister/lancer).

- Menu **Ressources** → **Modèles** (Job Templates) → **Ajouter** → **Modèle de job**.
- **Nom** : ex. `Configurer les nœuds` ou `Deploy app`.
- **Projet** : choisis **Projet-Ynov** (ton projet Git).
- **Playbook** : saisis le chemin complet depuis la racine du repo, ex. `ansible/playbooks/configure-nodes.yml` ou `ansible/playbooks/deploy-app.yml` (si le projet n’a pas de « Répertoire Playbook », c’est la seule façon de cibler le bon dossier).
- **Inventaire** : choisis l’inventaire que tu viens de créer (ex. `GCP`).
- **Identifiants** : si ton playbook se connecte en SSH aux hôtes, ajoute une credential de type **Machine** (utilisateur + clé SSH ou mot de passe). Sinon tu peux laisser vide pour tester.
- **Enregistrer**.

### 4. Lancer un job

- Dans **Modèles**, clique sur le nom du Job Template → bouton **Lancer** (ou **Launch**). Le job s’exécute ; tu vois les logs en direct.
- Une fois au moins un Job Template créé, **Kura** (si configuré avec l’URL et les identifiants AWX) pourra afficher ces jobs et les lancer depuis son interface.

Récap : **Projet** (déjà fait) → **Inventaire** (hôtes) → **Job Template** (projet + playbook + inventaire) → lancer. Détails Kura dans **KURA-AWX.md**.

---

## Références

- [AWX](https://github.com/ansible/awx) — projet officiel
- [AWX Operator](https://github.com/ansible/awx-operator) — déploiement sur Kubernetes
- [awx-without-k8s](https://github.com/fitbeard/awx-without-k8s) — déploiement Docker sans K8s
