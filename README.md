# Docker Pipeline ML EC2 Lab

This project implements a machine learning pipeline for document processing and semantic search using AWS EC2 and Docker containers. It processes PDF documents, generates embeddings, and enables semantic search capabilities using ChromaDB and Ollama.

## Features

- PDF document processing and text extraction
- Text chunking and embedding generation using Ollama
- Vector storage and semantic search using ChromaDB
- Data processing with Apache Spark and Delta Lake
- S3 integration for data storage
- Infrastructure as Code using Terraform

## Architecture

- **Infrastructure**: AWS EC2 instance with Docker and Docker Compose
- **Storage**: 
  - S3 bucket for file storage
  - Delta Lake tables for processed data
  - ChromaDB for vector storage
- **Processing**: 
  - Apache Spark for data processing
  - Ollama for text embeddings
  - ChromaDB for vector search
- **Security**: IAM roles and security groups for secure access
- **Containers**: Docker containers for the ML pipeline components

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed
- Docker installed (for local development)

## Setup

1. Configure AWS credentials:
   ```bash
   # Create a .env file from the example
   cp .env.example .env
   
   # Edit the .env file with your AWS credentials
   AWS_ACCESS_KEY_ID=your_access_key
   AWS_SECRET_ACCESS_KEY=your_secret_key
   ```

   The `.env` file should contain your AWS credentials in the following format:
   ```bash
   AWS_ACCESS_KEY_ID=your_access_key
   AWS_SECRET_ACCESS_KEY=your_secret_key
   ```

   Make sure to replace the placeholder values with your actual AWS credentials. Never commit the `.env` file to version control.

2. Deploy the infrastructure:
   ```bash
   # Make the scripts executable
   chmod +x scripts/*.sh

   # Deploy the infrastructure using the deploy script
   ./scripts/deploy.sh
   ```

   The deployment script will:
   - Initialize Terraform
   - Apply the infrastructure changes
   - Set up the EC2 instance
   - Configure Docker and required services

3. After deployment, you can connect to the EC2 instance:
   ```bash
   # Download the private key from S3
   aws s3 cp s3://<bucket-name>/ssh/docker-pipeline-ml-ec2-lab-key.pem ./key.pem
   chmod 400 key.pem

   # Connect to the instance
   ssh -i key.pem ubuntu@<ec2-public-ip>
   ```

4. Once connected to the EC2 instance, navigate to the app directory and run the application:
   ```bash
   # Navigate to the app directory
   cd /home/ubuntu/app

   # The Docker Compose services should be running
   # You can verify with:
   docker ps

   # Run the main application using the start script
   ./scripts/start_process.sh
   ```

   Note: The application needs to be run manually after connecting to the EC2 instance. The Docker Compose services will be running in the background, but the main application process needs to be started explicitly.

5. Check the setup logs:
   ```bash
   cat /home/ubuntu/app/setup.log
   cat /home/ubuntu/app/process.log
   ```

## Project Structure

```
.
├── infra/               # Terraform infrastructure code
│   ├── provider.tf      # AWS provider configuration
│   ├── variables.tf     # Input variables definition
│   ├── ec2.tf          # EC2 instance configuration
│   ├── iam.tf          # IAM roles and policies
│   ├── s3.tf           # S3 bucket configuration
│   ├── networking.tf   # VPC and networking setup
│   └── ecr.tf          # ECR repository configuration
├── scripts/            # Setup and utility scripts
│   ├── deploy.sh       # Infrastructure deployment script
│   ├── destroy.sh      # Cleanup script
│   └── setup_ec2.sh    # EC2 instance setup script
├── src/                # Application source code
│   ├── main.py        # Main application logic
│   ├── helpers.py     # Helper functions
│   └── queries.py     # Search queries
├── data/              # Data files and storage
├── .env.example       # Example environment variables
├── docker-compose.yml # Docker Compose configuration
├── Dockerfile        # Docker image definition
├── pyproject.toml    # Python project configuration
├── .pre-commit-config.yaml # Pre-commit hooks
└── .pylintrc         # Python linting configuration
```

## Pipeline Flow

1. **Document Processing**:
   - PDF documents are read from S3
   - Text is extracted and split into chunks
   - Each chunk is processed and embedded using Ollama

2. **Data Storage**:
   - Processed data is stored in Delta Lake tables
   - Embeddings and metadata are stored in ChromaDB
   - Results are saved in JSONL format

3. **Search Capabilities**:
   - Semantic search using ChromaDB
   - Query results are saved to S3

## Monitoring and Logs

- Setup logs: `/home/ubuntu/app/setup.log`
- Docker container logs: `docker logs <container-name>`
- Application logs: Check the respective container logs
- Spark UI: Available through the EC2 instance's web interface

## Cleanup

To destroy all resources:
```bash
# Use the destroy script to clean up all resources
./scripts/destroy.sh
```

The destroy script will:
- Remove all AWS resources created by Terraform
- Clean up any temporary files
- Remove SSH keys and other sensitive data

## Notes

- The EC2 instance may take a few minutes to fully initialize
- All sensitive files (like SSH keys) are stored in S3
- The setup script automatically installs Docker, Docker Compose, and other dependencies
- The pipeline uses the Nomic Embed Text model through Ollama for generating embeddings
- Data is deduplicated before being stored in ChromaDB
