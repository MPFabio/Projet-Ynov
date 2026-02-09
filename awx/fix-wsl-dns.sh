#!/usr/bin/env bash
# Corrige le DNS dans WSL ("Temporary failure resolving").
# Lancer dans WSL : bash fix-wsl-dns.sh
# Puis OBLIGATOIRE : fermer WSL, dans PowerShell faire "wsl --shutdown", rouvrir WSL.

set -e
echo "=== Correction DNS WSL ==="

# 1. Forcer wsl.conf pour que WSL ne regenere plus resolv.conf
echo "Configuration de /etc/wsl.conf (generateResolvConf = false)"
if [ -f /etc/wsl.conf ]; then
  sudo sed -i '/\[network\]/,/^\[/ s/^generateResolvConf.*/generateResolvConf = false/' /etc/wsl.conf 2>/dev/null || true
  if ! grep -q "generateResolvConf" /etc/wsl.conf; then
    printf '\n[network]\ngenerateResolvConf = false\n' | sudo tee -a /etc/wsl.conf
  fi
else
  printf '[network]\ngenerateResolvConf = false\n' | sudo tee /etc/wsl.conf
fi
grep -A1 "\[network\]" /etc/wsl.conf || true

# 2. Ecrire resolv.conf (sera pris en compte au prochain demarrage WSL si wsl.conf est bon)
echo ""
echo "Mise a jour de /etc/resolv.conf"
echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" | sudo tee /etc/resolv.conf

# 3. Test
echo ""
echo "Test reseau (ping IP) :"
ping -c 1 8.8.8.8 && echo "  -> OK : reseau WSL actif." || echo "  -> Echec : pas de reseau (firewall Windows, VPN, ou WSL a reinitialiser)."
echo ""
echo "Test DNS (ping nom) :"
ping -c 1 archive.ubuntu.com && echo "  -> OK : DNS fonctionne." || echo "  -> Echec : normal tant que WSL n a pas redemarre avec la nouvelle config."
echo ""
echo "=========================================="
echo "IMPORTANT : pour que le DNS soit pris en compte :"
echo "  1. Tapez  exit  (ou fermez cette fenetre WSL)"
echo "  2. Dans PowerShell (Windows) :  wsl --shutdown"
echo "  3. Rouvrez WSL (Ubuntu)"
echo "  4. Test :  ping archive.ubuntu.com"
echo "  5. Si OK :  sudo apt update && sudo apt install -y ansible git"
echo "=========================================="
