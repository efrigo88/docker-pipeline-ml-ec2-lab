locals {
  bucket_name = "${var.project_name}-${var.environment}-${formatdate("YYYYMMDD", timestamp())}"
}
