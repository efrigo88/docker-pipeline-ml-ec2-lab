# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "docker-pipeline-ml-ec2-lab"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
  default     = "140023373701"
}
