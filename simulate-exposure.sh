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

# Simulate Secret Exposure

# Retrieve AWS Secret
echo "Retrieving AWS Secret..."
AWS_SECRET=$(vault read -format=json aws/creds/iam-role)
if [ $? -ne 0 ]; then
  echo "Error: Failed to retrieve AWS secret."
  exit 1
fi
echo "AWS Secret:"
echo "$AWS_SECRET"

# Check if the Test Secret Exists
echo "Checking if test secret exists..."
if ! vault kv get secret/myapp/config > /dev/null 2>&1; then
  echo "Test secret not found. Writing a new test secret..."
  vault kv put secret/myapp/config username="example-user" password="example-password"
fi

# Retrieve the Test Secret
echo "Retrieving test secret..."
TEST_SECRET=$(vault kv get -format=json secret/myapp/config)
if [ $? -ne 0 ]; then
  echo "Error: Failed to retrieve test secret."
  exit 1
fi
echo "Test Secret:"
echo "$TEST_SECRET"

# Save Exposed Secrets to a File (optional)
echo "Saving exposed secrets to 'exposed-secrets.json'..."
cat <<EOF > exposed-secrets.json
{
  "aws_secret": $AWS_SECRET,
  "test_secret": $TEST_SECRET
}
EOF

echo "Secrets have been exposed and saved in 'exposed-secrets.json'."
