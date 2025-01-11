#!/bin/bash

# Set Vault Address
export VAULT_ADDR='http://127.0.0.1:8200'

# Start Vault in Dev Mode
if ! curl -s $VAULT_ADDR/v1/sys/seal-status > /dev/null; then
  echo "Starting Vault in dev mode..."
  # Start Vault in dev mode and redirect output to a log file
  nohup vault server -dev > vault-dev.log 2>&1 &
  sleep 5 # Wait for Vault to start
fi

# Check if the log file exists
if [ ! -f vault-dev.log ]; then
  echo "Error: vault-dev.log not found. Vault may not have started correctly."
  exit 1
fi

# Extract Root Token from Logs
ROOT_TOKEN=$(grep "Root Token:" vault-dev.log | awk '{print $3}')
if [ -z "$ROOT_TOKEN" ]; then
  echo "Error: Could not extract root token. Check vault-dev.log."
  exit 1
fi
echo "Root Token: $ROOT_TOKEN"

# Login to Vault
vault login $ROOT_TOKEN

# Enable AWS Secrets Engine
echo "Enabling AWS Secrets Engine..."
vault secrets enable aws || echo "AWS Secrets Engine already enabled."

# Configure AWS Secrets Engine
echo "Configuring AWS Secrets Engine..."
vault write aws/config/root \
  access_key="" \
  secret_key="" \
  region="us-east-2"

# Create Vault Role for AWS
echo "Creating Vault Role..."
vault write aws/roles/iam-role \
  credential_type=iam_user \
  policy_arns="arn:aws:iam::aws:policy/AdministratorAccess"


echo "Vault setup  completed successfully."

