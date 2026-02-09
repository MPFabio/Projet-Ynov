# Deploiement AWX avec awx-without-k8s (Docker, pas de K8s)
# Usage : .\setup-awx-docker.ps1

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

$RepoDir = Join-Path $ScriptDir "awx-without-k8s"
$InventoryPath = Join-Path $ScriptDir "inventory-local"

Write-Host "=== Verification des prerequis ===" -ForegroundColor Cyan
# Sur Windows, Ansible (contrôleur) ne tourne pas : module Unix 'grp' absent
if ($env:OS -eq "Windows_NT") {
    Write-Host "Sur Windows, le playbook doit etre lance depuis WSL (Ansible ne tourne pas nativement)." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Dans un terminal WSL (Ubuntu, etc.) :" -ForegroundColor Cyan
    Write-Host "  cd /mnt/c/Users/fabio/Documents/Projet-Ynov/awx" -ForegroundColor White
    Write-Host "  sudo apt install -y ansible  # si besoin" -ForegroundColor White
    Write-Host "  echo '127.0.0.1   awx-1.demo.io' | sudo tee -a /etc/hosts" -ForegroundColor White
    Write-Host "  AWX_AUTO_YES=1 bash setup-awx-docker-wsl.sh" -ForegroundColor White
    Write-Host ""
    Write-Host "Voir README section 'Sur Windows : utiliser WSL'." -ForegroundColor Gray
    exit 0
}
if (-not (Get-Command ansible-playbook -ErrorAction SilentlyContinue)) {
    Write-Host "Ansible est requis. Installez-le : pip install ansible ou apt install ansible" -ForegroundColor Red
    exit 1
}
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker est requis. Demarrez Docker Desktop." -ForegroundColor Red
    exit 1
}

Write-Host "Le playbook utilise le hostname awx-1.demo.io." -ForegroundColor Yellow
Write-Host "Assurez-vous que votre fichier hosts contient : 127.0.0.1   awx-1.demo.io" -ForegroundColor Yellow
Write-Host "  (Windows : C:\Windows\System32\drivers\etc\hosts en admin)" -ForegroundColor Gray
if (-not $env:AWX_AUTO_YES) {
    $r = Read-Host "Continuer ? (o/n)"
    if ($r -ne "o" -and $r -ne "O") { exit 0 }
}

if (-not (Test-Path $RepoDir)) {
    Write-Host "=== Clone de awx-without-k8s ===" -ForegroundColor Cyan
    git clone https://github.com/fitbeard/awx-without-k8s.git $RepoDir
    if ($LASTEXITCODE -ne 0) { Write-Host "Erreur clone git." -ForegroundColor Red; exit 1 }
} else {
    Write-Host "Dossier awx-without-k8s deja present." -ForegroundColor Gray
}

Write-Host "=== Lancement du playbook (inventaire local) ===" -ForegroundColor Cyan
$DemoDir = Join-Path $RepoDir "demo"
Push-Location $DemoDir
try {
    ansible-playbook -i $InventoryPath demo.yml --diff
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Le playbook a echoue. Verifiez l inventaire et le fichier hosts." -ForegroundColor Red
        exit 1
    }
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "=== AWX deploye ===" -ForegroundColor Green
Write-Host "Acces : http://awx-1.demo.io (ou l URL indiquee par le playbook)" -ForegroundColor White
Write-Host "Utilisateur par defaut : admin. Mot de passe : voir les variables du demo awx-without-k8s." -ForegroundColor Gray
