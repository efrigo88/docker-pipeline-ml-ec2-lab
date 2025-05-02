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
│   ├── main.py        # Main application logic
│   ├── helpers.py     # Helper functions
│   └── queries.py     # Search queries
├── data/               # Data files
├── docker-compose.yml  # Docker Compose configuration
└── Dockerfile         # Docker image definition
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
cd infra
terraform destroy
```

## Notes

- The EC2 instance may take a few minutes to fully initialize
- All sensitive files (like SSH keys) are stored in S3
- The setup script automatically installs Docker, Docker Compose, and other dependencies
- The pipeline uses the Nomic Embed Text model through Ollama for generating embeddings
- Data is deduplicated before being stored in ChromaDB
