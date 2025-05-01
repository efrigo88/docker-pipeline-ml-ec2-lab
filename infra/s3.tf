resource "aws_s3_bucket" "project_files" {
  bucket = local.bucket_name

  tags = {
    Name        = "data-pipeline-files"
    Environment = var.environment
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "project_files" {
  bucket = aws_s3_bucket.project_files.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload project files to S3
resource "aws_s3_object" "docker_compose" {
  depends_on = [aws_s3_bucket_public_access_block.project_files]
  bucket     = aws_s3_bucket.project_files.id
  key        = "docker-compose.yml"
  source     = "${path.module}/../docker-compose.yml"
  etag       = filemd5("${path.module}/../docker-compose.yml")
}

resource "aws_s3_object" "setup_script" {
  depends_on = [aws_s3_bucket_public_access_block.project_files]
  bucket     = aws_s3_bucket.project_files.id
  key        = "scripts/setup_ec2.sh"
  source     = "${path.module}/../scripts/setup_ec2.sh"
  etag       = filemd5("${path.module}/../scripts/setup_ec2.sh")
}

resource "aws_s3_object" "dockerfile" {
  depends_on = [aws_s3_bucket_public_access_block.project_files]
  bucket     = aws_s3_bucket.project_files.id
  key        = "Dockerfile"
  source     = "${path.module}/../Dockerfile"
  etag       = filemd5("${path.module}/../Dockerfile")
}

resource "aws_s3_object" "pyproject" {
  depends_on = [aws_s3_bucket_public_access_block.project_files]
  bucket     = aws_s3_bucket.project_files.id
  key        = "pyproject.toml"
  source     = "${path.module}/../pyproject.toml"
  etag       = filemd5("${path.module}/../pyproject.toml")
}

# Upload source code directory
resource "aws_s3_object" "src_files" {
  depends_on = [aws_s3_bucket_public_access_block.project_files]
  for_each   = fileset("${path.module}/../src", "**/*")

  bucket = aws_s3_bucket.project_files.id
  key    = "src/${each.value}"
  source = "${path.module}/../src/${each.value}"
  etag   = filemd5("${path.module}/../src/${each.value}")
}

# Upload data directory
resource "aws_s3_object" "data_files" {
  depends_on = [aws_s3_bucket_public_access_block.project_files]
  for_each   = fileset("${path.module}/../data", "**/*")

  bucket = aws_s3_bucket.project_files.id
  key    = "data/${each.value}"
  source = "${path.module}/../data/${each.value}"
  etag   = filemd5("${path.module}/../data/${each.value}")
}

output "bucket_name" {
  value       = aws_s3_bucket.project_files.id
  description = "Name of the S3 bucket"
}
