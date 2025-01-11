#!/bin/bash

# Set Vault Address
export VAULT_ADDR='http://127.0.0.1:8200'

# Start Vault in Dev Mode
if ! curl -s $VAULT_ADDR/v1/sys/seal-status > /dev/null; then
  echo "Starting Vault in dev mode..."

  # Ensure the log file exists
  touch vault-dev.log

  # Start Vault in dev mode and redirect output to the log file
  nohup vault server -dev > vault-dev.log 2>&1 &

  # Give some time for Vault to start
  sleep 5

  # Check if Vault is running
  if ! pgrep -f "vault server -dev" > /dev/null; then
    echo "Error: Vault process not running. Checking logs for details..."
    cat vault-dev.log # Print the log for debugging
    exit 1
  fi
fi

# Verify the log file exists
if [ ! -f vault-dev.log ]; then
  echo "Error: vault-dev.log not found. Vault may not have started correctly."
  exit 1
fi

echo "Vault started successfully. Log file: vault-dev.log"

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
if ! vault secrets enable aws; then
  echo "AWS Secrets Engine already enabled."
fi

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

echo "Vault setup completed successfully."
