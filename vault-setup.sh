# vault-setup.sh
#!/bin/bash
export VAULT_ADDR='http://127.0.0.1:8200'

# Initialize Vault
vault operator init > vault-init.txt

# Unseal Vault
UNSEAL_KEY=$(grep 'Unseal Key 1:' vault-init.txt | awk '{print $4}')
vault operator unseal $UNSEAL_KEY

# Login to Vault
ROOT_TOKEN=$(grep 'Initial Root Token:' vault-init.txt | awk '{print $4}')
vault login $ROOT_TOKEN

# Enable AWS Secrets Engine
vault secrets enable aws

# Configure AWS Secrets Engine
vault write aws/config/root \
  access_key="YOUR_ACCESS_KEY" \
  secret_key="YOUR_SECRET_KEY" \
  region="us-west-2"

vault write aws/roles/ec2-role \
  credential_type=iam_user \
  policy_arns="arn:aws:iam::aws:policy/ReadOnlyAccess"
