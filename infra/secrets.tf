# AWS Account ID
# If the secret is marked as deleted, restore it with:
# aws secretsmanager delete-secret --secret-id aws-account-id --force-delete-without-recovery --region eu-west-1 | cat
resource "aws_secretsmanager_secret" "aws_account_id" {
  name                    = "aws-account-id"
  description             = "AWS Account ID for the project"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "aws_account_id" {
  secret_id     = aws_secretsmanager_secret.aws_account_id.id
  secret_string = "140023373701"
}
