 simulate-exposure.sh
#!/bin/bash
# Simulate credential exposure by listing active AWS resources with exposed keys
export AWS_ACCESS_KEY_ID="EXPOSED_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="EXPOSED_SECRET_KEY"

# Simulate malicious action (e.g., listing S3 buckets)
echo "Simulating credential exposure..."
aws s3 ls

# Log the simulated exposure
echo "Simulated exposure complete. Check AWS CloudTrail for logs."
