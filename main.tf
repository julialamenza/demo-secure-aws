resource "aws_instance" "secure_instance" {
  ami                  = "ami-00eb69d236edcfaf8" # Ubuntu Server 22.04 LTS
  instance_type        = "t2.micro"
  key_name             = "demo" # Replace with your Key Pair name
  iam_instance_profile = aws_iam_instance_profile.ec2_role.name

  tags = {
    Name = "Secure-EC2"
  }


resource "aws_ebs_volume" "secure_volume" {
  availability_zone = aws_instance.secure_instance.availability_zone
  size              = 10
  tags = {
    Name = "Secure-Volume"
  }
}

resource "aws_volume_attachment" "secure_attachment" {
  device_name  = "/dev/xvdf" # Logical name for the device in the OS
  volume_id    = aws_ebs_volume.secure_volume.id
  instance_id  = aws_instance.secure_instance.id
  force_detach = true # Ensures the volume can be re-attached if necessary
}

resource "aws_iam_instance_profile" "ec2_role" {
  name = "ec2-secure-role"
  role = aws_iam_role.ec2_role.name
}

data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "ec2-secure-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2-access-policy"
  description = "Policy to allow EC2 instances access to specific resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::example-bucket",
          "arn:aws:s3:::example-bucket/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_role_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_cloudtrail" "trail" {
  name                          = "demo-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
}

resource "aws_s3_bucket" "cloudtrail" {
  bucket = "cloudtrail-logs-${random_id.bucket_id.hex}"

  tags = {
    Name = "CloudTrail Bucket"
  }
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.bucket

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action = "s3:PutObject",
        Resource = "${aws_s3_bucket.cloudtrail.arn}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action = "s3:GetBucketAcl",
        Resource = aws_s3_bucket.cloudtrail.arn
      }
    ]
  })
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

resource "random_id" "bucket_id" {
  byte_length = 8
}
