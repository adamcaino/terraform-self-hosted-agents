# This script retrieves the SSH private key from Azure Key Vault
# and saves it to a file named admin_ssh_key_windows.pem with secure permissions.

# Usage: .\get_ssh_key.ps1 -KeyVaultName "myKeyVault" -SecretName "mySecret"

param (
  [Parameter(Mandatory = $true)]
  [string]$KeyVaultName,

  [Parameter(Mandatory = $true)]
  [string]$SecretName
)

# Log in to Azure
az login

# Download the secret and save it to a PEM file
az keyvault secret show `
  --vault-name $KeyVaultName `
  --name $SecretName `
  --query value -o tsv > admin_ssh_key_windows.pem

# Restrict permissions (like chmod 600)
icacls admin_ssh_key_windows.pem /inheritance:r
icacls admin_ssh_key_windows.pem /grant:r "$($env:USERNAME):(R)"
icacls admin_ssh_key_windows.pem /remove "Authenticated Users" "Everyone"
