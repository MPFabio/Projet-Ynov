# Faire communiquer Kura et AWX

Pour que l’onglet **Ansible** de Kura (localhost:5173) affiche les jobs/templates d’AWX et puisse les lancer, il faut :

---

## 1. Dans AWX (http://localhost:8052)

### Projet (formulaire « Contrôle de la source » que tu as ouvert)

- **Nom** : par ex. `Projet-Ynov` (obligatoire).
- **Organisation** : laisser `Default`.
- **Type** : `Git`.
- **URL Contrôle de la source** : l’URL du dépôt Git qui contient les playbooks, par ex.  
  `https://github.com/<ton-user>/Projet-Ynov.git`  
  (ou l’URL de ton dépôt Projet-Ynov).
- **Branche** : `main` (ou la branche à utiliser).
- **Identifiant Contrôle de la source** : à remplir seulement si le dépôt est **privé** (credential Git / SSH ou token).

Enregistrer, puis cliquer sur **Actualiser** (↻) sur le projet pour que AWX récupère les playbooks.

### Ensuite dans AWX

- **Inventaires** → Ajouter un inventaire (ex. `GCP`), ajouter les hôtes ou un script d’inventaire.
- **Modèles (Job Templates)** → Ajouter → choisir le **Projet** (Projet-Ynov), l’**Inventaire**, le **Playbook** (`configure-nodes.yml` ou `deploy-app.yml`), et une **Credential** si besoin. Enregistrer.

Une fois au moins un Job Template créé, AWX exposera des jobs que Kura pourra lister et lancer.

---

## 2. Dans Kura / ModulOps (ansible-service)

Le service **ansible-service** de Kura doit pointer vers AWX. Où que tourne Kura (Docker ou non), il faut que ce service ait :

| Variable | Valeur |
|----------|--------|
| `ANSIBLE_TOWER_URL` | `http://localhost:8052` (si Kura tourne sur la même machine que le port-forward AWX) ou `http://host.docker.internal:8052` (si Kura est dans Docker et AWX sur l’hôte) |
| `ANSIBLE_TOWER_USERNAME` | `admin` |
| `ANSIBLE_TOWER_PASSWORD` | le mot de passe admin AWX (récupéré avec `kubectl get secret -n awx awx-admin-password -o jsonpath='{.data.password}' \| base64 -d`) |
| `ANSIBLE_TOWER_VERIFY_SSL` | `false` (pour HTTP) |

- **Si Kura tourne en Docker Compose** : dans le `docker-compose` du projet ModulOps/Kura, dans la section du service **ansible-service**, ajouter ou modifier les variables d’environnement ci-dessus, puis redémarrer :  
  `docker compose up -d ansible-service`
- **Si l’ansible-service tourne en local** : exporter ces variables dans le terminal avant de lancer le service, ou les mettre dans un fichier `.env` utilisé au démarrage.

Après redémarrage, l’onglet **Ansible** de Kura (localhost:5173/ansible) devrait lister les Job Templates et jobs AWX, et tu pourras lancer les jobs depuis Kura.

---

## Récap

1. **AWX** : créer le Projet (Nom + URL Git), inventaire, puis au moins un Job Template.
2. **Kura** : configurer l’ansible-service avec l’URL d’AWX (8052) et les identifiants admin.
3. Garder le **port-forward** AWX actif (`kubectl port-forward -n awx svc/awx-service 8052:80`) tant que tu utilises Kura.
