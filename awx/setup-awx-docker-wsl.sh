#!/usr/bin/env bash
# Déploiement AWX (awx-without-k8s) — à lancer depuis WSL sur Windows.
# Usage : cd /mnt/c/Users/fabio/Documents/Projet-Ynov/awx && AWX_AUTO_YES=1 bash setup-awx-docker-wsl.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

REPO_DIR="$SCRIPT_DIR/awx-without-k8s"
INVENTORY_PATH="$SCRIPT_DIR/inventory-local"

echo "=== Vérification des prérequis (WSL) ==="
if ! command -v ansible-playbook &>/dev/null; then
  echo "Ansible est requis. Installez-le : sudo apt install ansible   ou   pip install ansible"
  exit 1
fi
if ! command -v docker &>/dev/null; then
  echo "Docker est requis (Docker Desktop avec WSL2 ou docker.io dans WSL)."
  exit 1
fi

echo "Hostname utilisé par le playbook : awx-1.demo.io"
echo "Vérifiez que /etc/hosts contient : 127.0.0.1   awx-1.demo.io"
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
echo "Accès : http://awx-1.demo.io (ajoutez 127.0.0.1 awx-1.demo.io dans le fichier hosts Windows pour le navigateur)"
echo "Utilisateur : admin. Mot de passe : voir les variables du demo awx-without-k8s."
