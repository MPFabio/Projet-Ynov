#!/usr/bin/env bash
# Déploiement AWX avec awx-without-k8s (Docker, pas de K8s)
# Usage : ./setup-awx-docker.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

REPO_DIR="$SCRIPT_DIR/awx-without-k8s"
INVENTORY_PATH="$SCRIPT_DIR/inventory-local"

echo "=== Vérification des prérequis ==="
if ! command -v ansible-playbook &>/dev/null; then
  echo "Ansible est requis. Installez-le : pip install ansible"
  exit 1
fi
if ! command -v docker &>/dev/null; then
  echo "Docker est requis."
  exit 1
fi

echo "Le playbook utilise le hostname awx-1.demo.io."
echo "Assurez-vous que /etc/hosts contient : 127.0.0.1   awx-1.demo.io"
if [ -z "$AWX_AUTO_YES" ]; then
  read -p "Continuer ? (o/n) " r
  if [ "$r" != "o" ] && [ "$r" != "O" ]; then exit 0; fi
fi

if [ ! -d "$REPO_DIR" ]; then
  echo "=== Clone de awx-without-k8s ==="
  git clone https://github.com/fitbeard/awx-without-k8s.git "$REPO_DIR"
fi

echo "=== Lancement du playbook (inventaire local) ==="
cd "$REPO_DIR/demo"
ansible-playbook -i "$INVENTORY_PATH" demo.yml --diff

echo ""
echo "=== AWX déployé ==="
echo "Accès : http://awx-1.demo.io (ou l'URL indiquée par le playbook)"
echo "Utilisateur par défaut : admin. Mot de passe : voir les variables du demo awx-without-k8s."
