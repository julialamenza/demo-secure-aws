# remediation.sh
#!/bin/bash
# Remediate exposed credentials using Vault dynamic secrets
export VAULT_ADDR='http://127.0.0.1:8200'

# Authenticate with Vault
vault login <VAULT_ROOT_TOKEN>

# Rotate IAM credentials
echo "Generating new IAM credentials using Vault..."
vault read aws/creds/ec2-role > new-creds.txt

NEW_ACCESS_KEY=$(grep access_key new-creds.txt | awk '{print $2}')
NEW_SECRET_KEY=$(grep secret_key new-creds.txt | awk '{print $2}')

# Update AWS CLI configuration
aws configure set aws_access_key_id $NEW_ACCESS_KEY
aws configure set aws_secret_access_key $NEW_SECRET_KEY

# Verify remediation
echo "New credentials have been configured. Verifying access..."
aws s3 ls

# Revoke old IAM credentials in Vault to ensure they are no longer valid
echo "Revoking old IAM credentials in Vault..."
vault lease revoke -prefix aws/creds/ec2-role
echo "Old credentials revoked successfully."
