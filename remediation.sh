#!/bin/bash

# Set Vault Address
export VAULT_ADDR='http://127.0.0.1:8200'

# Revoke Current AWS Credentials
echo "Revoking current AWS credentials..."
vault lease revoke -prefix aws/creds/iam-role

# Generate New AWS Credentials
NEW_AWS_SECRET=$(vault read -format=json aws/creds/iam-role)
if [ -z "$NEW_AWS_SECRET" ]; then
  echo "Error: Failed to generate new AWS credentials."
  exit 1
fi

# Parse New Credentials
NEW_AWS_ACCESS_KEY=$(echo "$NEW_AWS_SECRET" | jq -r '.data.access_key')
NEW_AWS_SECRET_KEY=$(echo "$NEW_AWS_SECRET" | jq -r '.data.secret_key')

if [ -z "$NEW_AWS_ACCESS_KEY" ] || [ -z "$NEW_AWS_SECRET_KEY" ]; then
  echo "Error: Failed to parse new AWS credentials."
  exit 1
fi

# Output New Credentials
echo "New AWS Access Key: $NEW_AWS_ACCESS_KEY"
echo "New AWS Secret Key: (hidden for security)"

# Export New Credentials
export AWS_ACCESS_KEY_ID="$NEW_AWS_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="$NEW_AWS_SECRET_KEY"

echo " AWS credentials have been  rotate"
