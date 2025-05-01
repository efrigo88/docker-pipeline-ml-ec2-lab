#!/bin/bash

# Exit on error
set -e

# Check for required environment variables
if [ -z "$AWS_ACCOUNT_ID" ] || [ -z "$AWS_REGION" ]; then
    echo "❌ Required environment variables AWS_ACCOUNT_ID and AWS_REGION are not set"
    exit 1
fi

echo "🚀 Starting EC2 setup..."

# Install AWS CLI
echo "📦 Installing AWS CLI..."
apt-get update
apt-get install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Install Docker
echo "📦 Installing Docker..."
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

# Install Docker Compose
echo "📦 Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create app directory
echo "📁 Creating app directory..."
mkdir -p /home/ubuntu/app
chown -R ubuntu:ubuntu /home/ubuntu/app

# Get the current bucket name
echo "🔍 Getting current bucket name..."
BUCKET_NAME=$(aws s3 ls | grep "docker-pipeline-ml-ec2-lab-${ENVIRONMENT:-dev}" | awk '{print $3}')

if [ -z "$BUCKET_NAME" ]; then
    echo "❌ Could not find the S3 bucket"
    exit 1
fi

# Download files from S3
echo "⬇️  Downloading files from S3..."
aws s3 sync s3://${BUCKET_NAME}/ /home/ubuntu/app/
chown -R ubuntu:ubuntu /home/ubuntu/app

# Login to ECR and start containers
echo "🚀 Starting containers..."
su - ubuntu -c "
  aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
  cd /home/ubuntu/app
  docker-compose up -d
"

# Wait for Ollama container to be ready
echo "⏳ Waiting for Ollama container to be ready..."
sleep 10

# Pull the model
echo "📥 Pulling nomic-embed-text model..."
docker exec ollama ollama pull nomic-embed-text

echo "✅ EC2 setup completed successfully!"