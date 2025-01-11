#!/bin/bash

# Set Vault Address
export VAULT_ADDR='http://127.0.0.1:8200'

# Retrieve Root Token from Log
if [ ! -f vault-dev.log ]; then
echo "Error: vault-dev.log not found. Please ensure Vault is running in dev mode."
exit 1
fi

ROOT_TOKEN=$(grep "Root Token:" vault-dev.log | awk '{print $3}')
if [ -z "$ROOT_TOKEN" ]; then
echo "Error: Could not extract root token. Check vault-dev.log."
exit 1
fi
echo "Root Token: $ROOT_TOKEN"

# Login to Vault
vault login $ROOT_TOKEN

# Retrieve AWS Temporary Credentials from Vault
AWS_SECRET=$(vault read -format=json aws/creds/iam-role)
echo "Raw Vault Response: $AWS_SECRET"

# Export credentials
# export AWS_ACCESS_KEY_ID=""
# export AWS_SECRET_ACCESS_KEY=""

echo "AWS credentials have been exposed "
