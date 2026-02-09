#!/usr/bin/env bash
# Corrige le conflit Signed-By du depot Google Cloud SDK pour que apt update fonctionne.
# A lancer dans WSL : bash fix-apt-wsl.sh (eventuellement avec sudo pour les etapes finales)

set -e
echo "=== Recherche des sources cloud-sdk ==="
for f in /etc/apt/sources.list /etc/apt/sources.list.d/*.list; do
  [ -f "$f" ] || continue
  if grep -q "cloud.google.com" "$f" 2>/dev/null; then
    echo "  Trouve: $f"
  fi
done

echo ""
echo "=== Desactivation des fichiers cloud-sdk en conflit ==="
for f in /etc/apt/sources.list.d/google-cloud-sdk.list /etc/apt/sources.list.d/google-cloud-sdk.list.distUpgrade; do
  if [ -f "$f" ]; then
    echo "  Renommage $f -> $f.bak"
    sudo mv "$f" "$f.bak"
  fi
done

# Si la ligne est dans sources.list, on la commente
if sudo grep -q "packages.cloud.google.com" /etc/apt/sources.list 2>/dev/null; then
  echo "  Commentaire de la ligne cloud-sdk dans /etc/apt/sources.list"
  sudo sed -i.bak '/packages.cloud.google.com/s/^/#/' /etc/apt/sources.list
fi

echo ""
echo "=== Mise a jour APT ==="
sudo apt update

echo ""
echo "=== Installation ansible et git ==="
sudo apt install -y ansible git

echo ""
echo "Termine. Vous pouvez lancer : cd /mnt/c/Users/fabio/Documents/Projet-Ynov/awx && AWX_AUTO_YES=1 bash setup-awx-docker-wsl.sh"
