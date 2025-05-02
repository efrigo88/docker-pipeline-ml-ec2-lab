# AWS Account ID
resource "aws_secretsmanager_secret" "aws_account_id" {
  name        = "aws-account-id"
  description = "AWS Account ID for the project"
}

resource "aws_secretsmanager_secret_version" "aws_account_id" {
  secret_id     = aws_secretsmanager_secret.aws_account_id.id
  secret_string = "140023373701"
}
