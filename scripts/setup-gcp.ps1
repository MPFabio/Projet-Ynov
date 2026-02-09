# Génère terraform/terraform.tfvars avec le project ID GCP actuel (gcloud config).
$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$Tfvars = Join-Path $RepoRoot "terraform\terraform.tfvars"

if (-not (Get-Command gcloud -ErrorAction SilentlyContinue)) {
    Write-Error "gcloud non trouvé. Installez le Google Cloud SDK."
    exit 1
}

$ProjectId = gcloud config get-value project 2>$null
if ([string]::IsNullOrWhiteSpace($ProjectId) -or $ProjectId -eq "(unset)") {
    Write-Error "Aucun projet GCP configuré. Lancez: gcloud config set project VOTRE_PROJECT_ID"
    exit 1
}

Write-Host "Project ID GCP: $ProjectId"
@"
project_id     = "$ProjectId"
project_name   = "projet-ynov"
region         = "europe-west1"
environment    = "dev"
node_count     = 2
node_max_count = 5
"@ | Set-Content -Path $Tfvars -Encoding UTF8
Write-Host "Écrit: $Tfvars"
Write-Host "Vous pouvez lancer: cd terraform; terraform init; terraform plan"
