#!/usr/bin/env python3
"""
Récupère la clé privée SSH Ansible pour l'utiliser dans AWX (credential Machine)
ou en local. La clé est générée par Terraform et soit enregistrée dans un fichier
local (terraform/.ansible_ssh_private_key), soit dans GCP Secret Manager.

Usage:
  # Depuis Secret Manager (après terraform apply et gcloud auth)
  python get_ansible_ssh_key.py --source secret
  python get_ansible_ssh_key.py --source secret > awx_key.txt

  # Depuis le fichier local (créé par Terraform)
  python get_ansible_ssh_key.py --source file
  python get_ansible_ssh_key.py --source file --path terraform/.ansible_ssh_private_key

Variables d'environnement (optionnel):
  GCP_PROJECT_ID  - projet GCP (pour --source secret)
  ANSIBLE_SSH_KEY_PATH - chemin du fichier clé (pour --source file)
"""

import argparse
import os
import sys


def get_key_from_file(path: str) -> str:
    if not os.path.isfile(path):
        sys.stderr.write(f"Fichier introuvable: {path}\n")
        sys.exit(1)
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def get_key_from_secret(project_id: str, secret_id: str) -> str:
    try:
        from google.cloud import secretmanager
    except ImportError:
        sys.stderr.write(
            "Pour --source secret, installez: pip install google-cloud-secret-manager\n"
        )
        sys.exit(1)
    client = secretmanager.SecretManagerServiceClient()
    name = f"projects/{project_id}/secrets/{secret_id}/versions/latest"
    response = client.access_secret_version(request={"name": name})
    return response.payload.data.decode("utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Récupère la clé privée SSH Ansible (Terraform)"
    )
    parser.add_argument(
        "--source",
        choices=["file", "secret"],
        default="secret",
        help="Source: file (local) ou secret (GCP Secret Manager)",
    )
    parser.add_argument(
        "--path",
        default=os.environ.get(
            "ANSIBLE_SSH_KEY_PATH",
            os.path.join(os.path.dirname(__file__), "..", "terraform", ".ansible_ssh_private_key"),
        ),
        help="Chemin du fichier clé (--source file)",
    )
    parser.add_argument(
        "--project",
        default=os.environ.get("GCP_PROJECT_ID"),
        help="Project ID GCP (--source secret). Sinon variable GCP_PROJECT_ID.",
    )
    parser.add_argument(
        "--secret",
        default="ansible-ssh-private-key",
        help="ID du secret dans Secret Manager",
    )
    args = parser.parse_args()

    if args.source == "file":
        key = get_key_from_file(args.path)
    else:
        if not args.project:
            sys.stderr.write("Indiquez --project ou la variable GCP_PROJECT_ID.\n")
            sys.exit(1)
        key = get_key_from_secret(args.project, args.secret)

    print(key, end="")


if __name__ == "__main__":
    main()
