# Backend GCS pour le tfstate (bucket kura-ynov)
terraform {
  backend "gcs" {
    bucket = "kura-ynov"
    prefix = "projet-ynov/terraform/state"
  }
}
