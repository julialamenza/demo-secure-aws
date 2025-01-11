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

# Revoke Old AWS Credentials
echo "Revoking old temporary AWS credentials..."
LEASE_IDS=$(vault list -format=json sys/leases/lookup/aws/creds/iam-role | jq -r '.[]')

if [ -n "$LEASE_IDS" ]; then
  for LEASE_ID in $LEASE_IDS; do
    echo "Revoking lease: $LEASE_ID"
    vault lease revoke "$LEASE_ID"
  done
  echo "All old temporary credentials revoked."
else
  echo "No existing temporary credentials to revoke."
fi

# Explicitly Cleanup IAM Users in AWS
echo "Checking for leftover IAM users in AWS..."
AWS_USER_PREFIX="vault-" # Default prefix for Vault-created users
IAM_USERS=$(aws iam list-users --query "Users[?starts_with(UserName, '${AWS_USER_PREFIX}')].UserName" --output text)

if [ -n "$IAM_USERS" ]; then
  echo "Found leftover IAM users. Deleting them..."
  for USER in $IAM_USERS; do
    echo "Deleting user: $USER"
    aws iam delete-user --user-name "$USER"
  done
  echo "All leftover IAM users deleted."
else
  echo "No leftover IAM users found."
fi

# Generate New AWS Temporary Credentials
echo "Generating new temporary AWS credentials for role 'iam-role'..."
NEW_AWS_CREDS=$(vault read -format=json aws/creds/iam-role)
if [ $? -ne 0 ]; then
  echo "Error: Failed to generate new AWS credentials."
  exit 1
fi

# Extract New Access and Secret Keys
NEW_ACCESS_KEY=$(echo "$NEW_AWS_CREDS" | jq -r '.data.access_key')
NEW_SECRET_KEY=$(echo "$NEW_AWS_CREDS" | jq -r '.data.secret_key')

# Output New Credentials
echo "New AWS Temporary Credentials:"
echo "Access Key: $NEW_ACCESS_KEY"
echo "Secret Key: $NEW_SECRET_KEY"

# Save New Credentials to a File
echo "Saving new AWS credentials to 'rotated-aws-creds.json'..."
cat <<EOF > rotated-aws-creds.json
{
  "access_key": "$NEW_ACCESS_KEY",
  "secret_key": "$NEW_SECRET_KEY"
}
EOF

echo "Remediation complete. New credentials saved to 'rotated-aws-creds.json'."
