#!/bin/bash

# Exit on error
set -e

# Define log file
LOG_FILE="/home/ubuntu/app/setup.log"

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check for required environment variables
if [ -z "$AWS_ACCOUNT_ID" ] || [ -z "$AWS_REGION" ]; then
    log "❌ Required environment variables AWS_ACCOUNT_ID and AWS_REGION are not set"
    exit 1
fi

log "🚀 Starting EC2 setup..."

# Install Docker
log "📦 Installing Docker..."
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
log "📦 Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Get the current bucket name
log "🔍 Getting current bucket name..."
BUCKET_NAME=$(aws s3 ls | grep "docker-pipeline-ml-ec2-lab" | awk '{print $3}')

if [ -z "$BUCKET_NAME" ]; then
    log "❌ Could not find the S3 bucket"
    exit 1
fi

# Download files from S3
log "⬇️  Downloading files from S3..."
aws s3 sync s3://${BUCKET_NAME}/ /home/ubuntu/app/ 2>&1 | tee -a "$LOG_FILE"
chown -R ubuntu:ubuntu /home/ubuntu/app

# Login to ECR and start containers
log "🚀 Starting containers..."
su - ubuntu -c "
  aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
  cd /home/ubuntu/app
  docker-compose up -d
" 2>&1 | tee -a "$LOG_FILE"

# Wait for Ollama container to be ready
log "⏳ Waiting for Ollama container to be ready..."
sleep 10

# Pull the model
log "📥 Pulling nomic-embed-text model..."
docker exec ollama ollama pull nomic-embed-text 2>&1 | tee -a "$LOG_FILE"

log "✅ EC2 setup completed successfully!"