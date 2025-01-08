resource "aws_instance" "secure_instance" {
  ami           = "ami-12345678" # Replace with a valid AMI
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.ec2_role.name

  tags = {
    Name = "Secure-EC2"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y wget curl unzip
    wget -O veeam-backup.deb https://repository.veeam.com/backup/linux/veeam-release.deb
    sudo dpkg -i veeam-backup.deb
    sudo apt-get update -y
    sudo apt-get install -y veeamsnap veeam
    sudo systemctl enable veeamsnap
    sudo systemctl start veeamsnap
    sudo systemctl enable veeamservice
    sudo systemctl start veeamservice
    echo "Veeam installation completed at $(date)" >> /var/log/veeam-install.log
  EOF
}

resource "aws_ebs_volume" "secure_volume" {
  availability_zone = "${var.region}a"
  size              = 10
  tags = {
    Name = "Secure-Volume"
  }
}

resource "aws_ebs_volume_attachment" "secure_attachment" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.secure_volume.id
  instance_id = aws_instance.secure_instance.id
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
  s3_bucket_name                = aws_s3_bucket.cloudtrail.name
  include_global_service_events = true
  is_multi_region_trail         = true
}

resource "aws_s3_bucket" "cloudtrail" {
  bucket = "cloudtrail-logs-${random_id.bucket_id.hex}"

  versioning {
    enabled = true
  }
}

resource "random_id" "bucket_id" {
  byte_length = 8
}
