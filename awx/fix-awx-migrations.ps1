# Debloquer AWX bloque sur "Waiting for database migrations"
# Relance les pods awx-task et awx-web pour rejouer les migrations.
# Usage : .\fix-awx-migrations.ps1

$ErrorActionPreference = "Stop"
Write-Host "Redemarrage des pods AWX (task + web) pour forcer les migrations..." -ForegroundColor Cyan
kubectl rollout restart deployment -n awx awx-task awx-web
Write-Host "Attente 2 min que les pods redemarrent..."
Start-Sleep -Seconds 120
kubectl get pods -n awx
Write-Host ""
Write-Host "Surveille les logs : kubectl logs -n awx -l app.kubernetes.io/name=awx-task -f --tail=50" -ForegroundColor Gray
Write-Host "Quand tu ne vois plus 'Waiting for database migrations', rafraichis http://localhost:8052" -ForegroundColor Gray
