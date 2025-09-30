#!/bin/bash
# This script retrieves the SSH private key from Azure Key Vault
# and saves it to a file named admin_ssh_key_bash.pem with secure permissions.

# Usage: ./get_ssh_key.sh <KeyVaultName> <SecretName>

set -euo pipefail

KeyVaultName="$1"
SecretName="$2"

# Log in to Azure
az login

# Download the secret from Key Vault
az keyvault secret show \
  --vault-name "$KeyVaultName" \
  --name "$SecretName" \
  --query value -o tsv > admin_ssh_key_bash.pem

# Restrict file permissions
chmod 600 admin_ssh_key_bash.pem

# Secure the file
chmod 600 admin_ssh_key_bash.pem
