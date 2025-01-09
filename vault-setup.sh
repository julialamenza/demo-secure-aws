#!/bin/bash

# Set Vault Address
export VAULT_ADDR='http://127.0.0.1:8200'

# Check if Vault is already initialized
if vault status | grep -q "Initialized.*true"; then
  echo "Vault is already initialized. Proceeding to unseal..."
else
  echo "Initializing Vault..."
  vault operator init > vault-init.txt

  # Extract the unseal key and root token
  UNSEAL_KEY=$(grep 'Unseal Key 1:' vault-init.txt | awk '{print $4}')
  ROOT_TOKEN=$(grep 'Initial Root Token:' vault-init.txt | awk '{print $4}')

  echo "Unseal Key and Root Token saved in vault-init.txt"
fi

# Unseal Vault
if [ -z "$UNSEAL_KEY" ]; then
  UNSEAL_KEY=$(grep 'Unseal Key 1:' vault-init.txt | awk '{print $4}')
fi
echo "Unsealing Vault..."
vault operator unseal $UNSEAL_KEY

# Login to Vault
if [ -z "$ROOT_TOKEN" ]; then
  ROOT_TOKEN=$(grep 'Initial Root Token:' vault-init.txt | awk '{print $4}')
fi
echo "Logging into Vault..."
vault login $ROOT_TOKEN

# Enable AWS Secrets Engine
echo "Enabling AWS Secrets Engine..."
vault secrets enable aws || echo "AWS Secrets Engine already enabled."

# Configure AWS Secrets Engine
echo "Configuring AWS Secrets Engine..."
vault write aws/config/root \
  access_key="" \
  secret_key="" \
  region="us-east-2" || exit 1

# Create Vault Role for AWS
echo "Creating Vault Role..."
vault write aws/roles/ec2-role \
  credential_type=iam_user \
  policy_arns="arn:aws:iam::aws:policy/ReadOnlyAccess" || exit 1

echo "Vault setup completed successfully."
