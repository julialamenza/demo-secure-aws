
# Demo: Secure and scaling AWS Infrastructure with Terraform, Vault, and Veeam

## Overview
This demo showcases how to secure AWS resources, remediate credential exposure, and implement robust backup solutions using Terraform, Vault, and Veeam.

### Key Components:
1. **Terraform**: Provision AWS infrastructure.
2. **Vault**: Manage and secure secrets dynamically.
3. **Veeam**: Backup and restore AWS resources.

---

## Prerequisites

### Tools You Need:
- **Terraform**: [Download](https://www.terraform.io/downloads)
- **Vault**: [Download](https://www.vaultproject.io/downloads)
- **AWS CLI**: [Install](https://aws.amazon.com/cli/)
- **Veeam Backup for AWS**: Installed and configured.

### AWS Account Requirements:
- Access to create and manage resources in AWS (IAM, EC2, S3, CloudTrail, etc.).
- An AWS IAM user with programmatic access (access key and secret key).

---

## Step-by-Step Instructions

### Step 1: Set Up the Project
1. Clone the repository or download the code:
   ```bash
   git clone https://github.com/your-demo-repo.git
   cd your-demo-repo
   ```

2. Edit the `terraform.tfvars` file to include your AWS credentials and region:
   ```plaintext
   region = "us-west-2"
   access_key = "YOUR_AWS_ACCESS_KEY"
   secret_key = "YOUR_AWS_SECRET_KEY"
   ```

### Step 2: Initialize Terraform
1. Run Terraform initialization:
   ```bash
   terraform init
   ```

2. Validate the configuration:
   ```bash
   terraform validate
   ```

### Step 3: Deploy the Infrastructure
1. Create a Terraform plan:
   ```bash
   terraform plan -out=tfplan
   ```

2. Apply the plan:
   ```bash
   terraform apply tfplan
   ```

3. Note the outputs for later use (e.g., instance ID, public IP).

ps:
---

### Step 4: Set Up Vault
1. Start Vault in dev mode:
   ```bash
   vault server -dev
   ```

2. Initialize and unseal Vault:
   ```bash
   ./vault-setup.sh
   ```

3. Verify AWS secrets engine setup in Vault:
   ```bash
   vault list aws/
   ```

---

### Step 5: Simulate Credential Exposure
1. Run the simulation script to mimic credential leakage:
   ```bash
   ./simulate-exposure.sh
   ```
2. Observe the actions (e.g., API calls using exposed credentials).

---

### Step 6: Remediate Credential Exposure
1. Run the remediation script to rotate credentials dynamically:
   ```bash
   ./remediation.sh
   ```
2. Verify the new credentials by listing resources:
   ```bash
   aws s3 ls
   ```

---

### Step 7: Configure Veeam for Backup and Restore
1. Set up **Veeam Backup for AWS**:
   - Add the AWS account to Veeam.
   - Create a backup policy for EC2 and EBS resources.

2. Trigger a manual backup and verify it.

3. Simulate a restore of the EC2 instance or EBS volume.

---

### Use Case: `backup-plan.tf`
If Veeam Backup for AWS is not available or is not configured, you can use the `backup-plan.tf` file as a fallback or alternative to ensure that backups are still automated and managed directly via AWS. This file uses AWS Backup to:
- Create a backup vault to store backup data.
- Define a backup plan with a schedule and retention policy.
- Automate backups of EC2 instances and EBS volumes.

AWS Backup is a cost-effective and AWS-native solution for managing backups, ensuring critical resources are protected even if third-party tools like Veeam are unavailable.

---
### Step 8: Cleanup
To avoid unnecessary costs, destroy all created resources:
```bash
terraform destroy
```

---

## Troubleshooting
- **Terraform Issues**:
  - Ensure your AWS credentials are valid.
  - Validate configurations with `terraform validate`.
- **Vault Setup**:
  - If Vault doesn't start, check for port conflicts.
  - Ensure the Vault server is running before executing scripts.
- **Veeam Setup**:
  - Verify AWS permissions are sufficient for backup and restore operations.

---