# Deploiement AWX sur GKE (sans WSL, sans Minikube)
# Usage : .\setup-awx-gke.ps1

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

$GKE_CONTEXT = "gke_kura-devops_europe-west1_projet-ynov-gke"

Write-Host "=== AWX sur GKE (sans WSL) ===" -ForegroundColor Cyan
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "kubectl est requis. Installez-le ou utilisez gcloud." -ForegroundColor Red
    exit 1
}
# Plugin requis pour que kubectl se connecte a GKE
if (-not (Get-Command gke-gcloud-auth-plugin -ErrorAction SilentlyContinue)) {
    Write-Host "Le plugin GKE pour kubectl est absent (gke-gcloud-auth-plugin)." -ForegroundColor Yellow
    Write-Host "Installez-le avec : gcloud components install gke-gcloud-auth-plugin" -ForegroundColor White
    Write-Host "Si gcloud n'est pas installe : https://cloud.google.com/sdk/docs/install" -ForegroundColor Gray
    exit 1
}

Write-Host "Contexte cible : $GKE_CONTEXT" -ForegroundColor Gray
kubectl config use-context $GKE_CONTEXT 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Contexte introuvable. Verifiez : kubectl config get-contexts" -ForegroundColor Yellow
    $ctx = kubectl config get-contexts -o name 2>$null | Select-Object -First 1
    if ($ctx) { Write-Host "Utilisez peut-etre : kubectl config use-context $ctx" -ForegroundColor Gray }
    exit 1
}

Write-Host "Creation du namespace awx..." -ForegroundColor Cyan
kubectl create namespace awx --dry-run=client -o yaml | kubectl apply -f -

Write-Host "Installation de l'AWX Operator (Kustomize)..." -ForegroundColor Cyan
kubectl apply -k $ScriptDir
Write-Host "Attente 90 s (operator + CRDs)..."
Start-Sleep -Seconds 90

Write-Host "Deploiement de l'instance AWX..." -ForegroundColor Cyan
kubectl apply -f (Join-Path $ScriptDir "awx-instance.yaml")
Write-Host "Attente des pods AWX (2-5 min)..."
$ready = $false
for ($i = 1; $i -le 40; $i++) {
    $pods = kubectl get pods -n awx -l app.kubernetes.io/name=awx-web --no-headers 2>$null
    if ($pods -match "Running") {
        Write-Host "Pods AWX prets." -ForegroundColor Green
        $ready = $true
        break
    }
    Write-Host "  ... ($i/40)"
    Start-Sleep -Seconds 10
}
if (-not $ready) {
    Write-Host "Timeout. Verifiez : kubectl get pods -n awx" -ForegroundColor Yellow
}

kubectl get pods -n awx
Write-Host ""
Write-Host "=== Acces AWX ===" -ForegroundColor Green
Write-Host "Mot de passe admin :"
$secret = kubectl get secret -n awx awx-admin-password -o jsonpath='{.data.password}' 2>$null
if ($secret) {
    [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($secret))
    Write-Host ""
}
Write-Host "Option 1 - Port-forward (depuis ce PC) :" -ForegroundColor Yellow
Write-Host "  kubectl port-forward -n awx svc/awx-service 8052:80" -ForegroundColor White
Write-Host "  Puis ouvrir : http://localhost:8052 (user: admin)" -ForegroundColor Gray
Write-Host ""
Write-Host "Option 2 - IP du LoadBalancer (quand assignee) :" -ForegroundColor Yellow
Write-Host "  kubectl get svc -n awx awx-service" -ForegroundColor White
Write-Host "  Ouvrir l'EXTERNAL-IP affichee (user: admin)" -ForegroundColor Gray
