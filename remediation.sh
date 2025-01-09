#!/bin/bash
# Rotate exposed credentials using Vault
export VAULT_ADDR='http://127.0.0.1:8200'
vault <Vault token> # Replace with the actual root token

echo "Generating new credentials using Vault..."
vault read aws/creds/ec2-role > new-creds.txt

NEW_ACCESS_KEY=$(grep access_key new-creds.txt | awk '{print $2}')
NEW_SECRET_KEY=$(grep secret_key new-creds.txt | awk '{print $2}')

echo "Updating AWS CLI with new credentials..."
aws configure set aws_access_key_id $NEW_ACCESS_KEY
aws configure set aws_secret_access_key $NEW_SECRET_KEY

echo "New credentials configured. Verifying..."
aws s3 ls

echo "Revoking old credentials..."
vault lease revoke aws/creds/ec2-role

echo "Rotation complete. Old credentials revoked."
