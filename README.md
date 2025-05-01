# Docker Pipeline ML EC2 Lab

This project sets up a machine learning pipeline on AWS EC2 using Docker containers. It includes infrastructure as code (Terraform) to provision the necessary AWS resources and automated setup scripts.

## Architecture

- **Infrastructure**: AWS EC2 instance with Docker and Docker Compose
- **Storage**: S3 bucket for file storage
- **Security**: IAM roles and security groups for secure access
- **Containers**: Docker containers for the ML pipeline components

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed
- Docker installed (for local development)

## Setup

1. Configure AWS credentials:
   ```bash
   export AWS_ACCESS_KEY_ID="your_access_key"
   export AWS_SECRET_ACCESS_KEY="your_secret_key"
   export AWS_REGION="your_region"
   export AWS_ACCOUNT_ID="your_account_id"
   ```

2. Deploy the infrastructure:
   ```bash
   cd infra
   terraform init
   terraform apply
   ```

3. After deployment, you can connect to the EC2 instance:
   ```bash
   # Download the private key from S3
   aws s3 cp s3://<bucket-name>/ssh/docker-pipeline-ml-ec2-lab-key.pem ./key.pem
   chmod 400 key.pem

   # Connect to the instance
   ssh -i key.pem ubuntu@<ec2-public-ip>
   ```

4. Check the setup logs:
   ```bash
   cat /home/ubuntu/app/setup.log
   ```

## Project Structure

```
.
├── infra/               # Terraform infrastructure code
│   ├── ec2.tf          # EC2 instance configuration
│   ├── iam.tf          # IAM roles and policies
│   ├── s3.tf           # S3 bucket configuration
│   └── vpc.tf          # VPC and networking setup
├── scripts/            # Setup and utility scripts
│   └── setup_ec2.sh    # EC2 instance setup script
├── src/                # Application source code
├── data/               # Data files
├── docker-compose.yml  # Docker Compose configuration
└── Dockerfile         # Docker image definition
```

## Monitoring and Logs

- Setup logs: `/home/ubuntu/app/setup.log`
- Docker container logs: `docker logs <container-name>`
- Application logs: Check the respective container logs

## Cleanup

To destroy all resources:
```bash
cd infra
terraform destroy
```

## Notes

- The EC2 instance may take a few minutes to fully initialize
- All sensitive files (like SSH keys) are stored in S3
- The setup script automatically installs Docker, Docker Compose, and other dependencies
