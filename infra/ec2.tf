locals {
  # https://aws.amazon.com/ec2/instance-types/
  instance_type = "t3.2xlarge"
}

# Create key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Save private key to S3
resource "aws_s3_object" "private_key" {
  bucket       = aws_s3_bucket.project_files.id
  key          = "ssh/${var.project_name}-key.pem"
  content      = tls_private_key.ssh_key.private_key_pem
  content_type = "text/plain"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Owner ID is Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Security group for EC2 instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-security-group"
  }
}

resource "aws_instance" "data-pipeline-ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = local.instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = aws_key_pair.ssh_key.key_name

  root_block_device {
    delete_on_termination = true
    volume_size           = 128
    volume_type           = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              
              # Download and execute setup script
              curl -o /tmp/setup_ec2.sh https://${local.bucket_name}.s3.${var.aws_region}.amazonaws.com/scripts/setup_ec2.sh
              chmod +x /tmp/setup_ec2.sh
              
              # Export variables for the setup script
              export AWS_ACCOUNT_ID="${var.aws_account_id}"
              export AWS_REGION="${var.aws_region}"
              export ENVIRONMENT="${var.environment}"
              
              # Run setup script
              /tmp/setup_ec2.sh
              EOF

  tags = {
    Name = "data-pipeline-ec2"
  }
}

output "ec2_public_ip" {
  value       = aws_instance.data-pipeline-ec2.public_ip
  description = "Public IP address of the EC2 instance"
}
