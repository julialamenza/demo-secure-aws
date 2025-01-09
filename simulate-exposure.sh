#!/bin/bash
# Simulate credential exposure using a test user's credentials
export AWS_ACCESS_KEY_ID="EXPOSED_TEST_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="EXPOSED_TEST_SECRET_KEY"

# Simulate malicious action (e.g., listing S3 buckets)
echo "Simulating credential exposure with test user credentials..."
aws s3 ls

# Log the simulated exposure
echo "Simulated exposure complete. Check AWS CloudTrail for logs."
