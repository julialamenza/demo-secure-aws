# outputs.tf
output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.secure_instance.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.secure_instance.public_ip
}

output "cloudtrail_bucket" {
  description = "CloudTrail log bucket name"
  value       = aws_s3_bucket.cloudtrail.bucket
}
