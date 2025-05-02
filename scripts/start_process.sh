#!/bin/bash

# Exit on error
set -e

# Define log file
LOG_FILE="/home/ubuntu/app/process.log"

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Fetch secrets from AWS Secrets Manager
log "🔑 Fetching AWS secrets..."
AWS_ACCOUNT_ID=$(aws secretsmanager get-secret-value --secret-id aws-account-id --query SecretString --output text)
AWS_REGION=$(aws secretsmanager get-secret-value --secret-id aws-region --query SecretString --output text)

# Check if secrets were retrieved successfully
if [ -z "$AWS_ACCOUNT_ID" ] || [ -z "$AWS_REGION" ]; then
    log "❌ Failed to retrieve AWS secrets from Secrets Manager"
    exit 1
fi

# Login to ECR and start containers
log "🚀 Starting containers..."
su - ubuntu -c "
  aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
  cd /home/ubuntu/app
  docker-compose up -d --build
" 2>&1 | tee -a "$LOG_FILE"

# Wait for Ollama container to be ready
log "⏳ Waiting for Ollama container to be ready..."
sleep 10

# Pull the model
log "📥 Pulling nomic-embed-text model..."
docker exec ollama ollama pull nomic-embed-text 2>&1 | tee -a "$LOG_FILE"

# Start the process
log "🚀 Starting the process..."
docker exec -it app python -m src.main 2>&1 | tee -a "$LOG_FILE"

log "✅ Process finished successfully!"