# Tout-en-un : installe le plugin GKE si besoin, puis deploie AWX sur GKE.
# Usage : .\setup-awx-tout.ps1

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

$GKE_CONTEXT = "gke_kura-devops_europe-west1_projet-ynov-gke"

# --- 1. S'assurer que gcloud et le plugin GKE sont disponibles ---
$gcloudPath = $null
if (Get-Command gcloud -ErrorAction SilentlyContinue) { $gcloudPath = (Get-Command gcloud).Source }
if (-not $gcloudPath) {
    $paths = @(
        "$env:ProgramFiles\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd",
        "${env:ProgramFiles(x86)}\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd",
        "$env:LOCALAPPDATA\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { $gcloudPath = $p; break }
    }
}
if (-not $gcloudPath) {
    Write-Host "gcloud introuvable. Installez le SDK : https://cloud.google.com/sdk/docs/install" -ForegroundColor Red
    exit 1
}

$gcloudDir = Split-Path (Split-Path $gcloudPath -Parent) -Parent
$pluginPath = Join-Path $gcloudDir "bin\gke-gcloud-auth-plugin.exe"
if (-not (Test-Path $pluginPath)) {
    Write-Host "Installation du plugin GKE (gke-gcloud-auth-plugin)..." -ForegroundColor Cyan
    & $gcloudPath components install gke-gcloud-auth-plugin --quiet 2>&1
    if (-not (Test-Path $pluginPath)) {
        Write-Host "Echec. Lancez a la main : gcloud components install gke-gcloud-auth-plugin" -ForegroundColor Red
        exit 1
    }
}
$env:PATH = "$(Join-Path $gcloudDir 'bin');$env:PATH"

if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "kubectl est requis. Installez-le : https://kubernetes.io/docs/tasks/tools/" -ForegroundColor Red
    exit 1
}

# --- 2. Contexte GKE ---
Write-Host "=== AWX sur GKE ===" -ForegroundColor Cyan
kubectl config use-context $GKE_CONTEXT 2>$null
if ($LASTEXITCODE -ne 0) {
    $ctx = (kubectl config get-contexts -o name 2>$null) | Select-Object -First 1
    if ($ctx) {
        Write-Host "Contexte utilise : $ctx" -ForegroundColor Gray
        kubectl config use-context $ctx
    } else {
        Write-Host "Aucun contexte kubectl. Configurez l'acces au cluster (gcloud container clusters get-credentials ...)." -ForegroundColor Red
        exit 1
    }
}

# --- 3. Namespace ---
Write-Host "Namespace awx..." -ForegroundColor Cyan
kubectl create namespace awx --dry-run=client -o yaml | kubectl apply -f - --validate=false 2>$null

# --- 4. AWX Operator ---
Write-Host "AWX Operator (Kustomize)..." -ForegroundColor Cyan
kubectl apply -k $ScriptDir --validate=false
if ($LASTEXITCODE -ne 0) {
    Write-Host "Erreur apply -k. Verifiez le reseau et les credentials GKE." -ForegroundColor Red
    exit 1
}
Write-Host "Attente 90 s..."
Start-Sleep -Seconds 90

# --- 5. Instance AWX ---
Write-Host "Instance AWX..." -ForegroundColor Cyan
kubectl apply -f (Join-Path $ScriptDir "awx-instance.yaml") --validate=false
Write-Host "Attente des pods (2-5 min)..."
$ready = $false
for ($i = 1; $i -le 40; $i++) {
    $pods = kubectl get pods -n awx -l app.kubernetes.io/name=awx-web --no-headers 2>$null
    if ($pods -match "Running") {
        $ready = $true
        break
    }
    Write-Host "  $i/40"
    Start-Sleep -Seconds 10
}

kubectl get pods -n awx
$secret = kubectl get secret -n awx awx-admin-password -o jsonpath='{.data.password}' 2>$null
$password = ""
if ($secret) { $password = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($secret)) }

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  AWX est deploye." -ForegroundColor Green
Write-Host "  URL : http://localhost:8052 (apres port-forward)" -ForegroundColor White
Write-Host "  User : admin" -ForegroundColor White
Write-Host "  Pass : $password" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Lancement du port-forward..." -ForegroundColor Cyan
Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "-n", "awx", "svc/awx-service", "8052:80" -WindowStyle Hidden
Start-Sleep -Seconds 3
Write-Host "Ouvre http://localhost:8052 dans ton navigateur (admin / mot de passe ci-dessus)." -ForegroundColor Yellow
Write-Host "Pour arreter le tunnel : Get-Process kubectl -ErrorAction SilentlyContinue | Stop-Process" -ForegroundColor Gray
