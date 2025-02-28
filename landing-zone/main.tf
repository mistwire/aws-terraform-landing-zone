########################################################################################
# Budgets and Billing
########################################################################################

resource "aws_budgets_budget" "monthly_budget" {
  name         = var.budget_name
  budget_type  = "COST"
  limit_amount = var.budget_amount
  limit_unit   = "USD"
  time_unit    = var.budget_time_unit

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.budget_threshold
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.budget_notification_email]
  }
}

########################################################################################
# Terraform Bootstrap Resources
########################################################################################

# Data source to get the IAM role ARN
data "aws_iam_role" "terraform_state_sso_principal_arn" {
  name = var.terraform_state_sso_principal_name
}

# S3 bucket to store Terraform state files
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = var.terraform_state_bucket_name

  tags = {
    Name = var.terraform_state_bucket_name
  }
}

# KMS key to encrypt objects in the S3 bucket
resource "aws_kms_key" "terraform_state_bucket" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

# KMS key alias
resource "aws_kms_alias" "terraform_state_bucket" {
  name          = var.terraform_state_kms_alias_name
  target_key_id = aws_kms_key.terraform_state_bucket.key_id
}

# Server-side encryption configuration for the S3 bucket using the KMS key
# Overrides default encryption settings, see: https://docs.aws.amazon.com/AmazonS3/latest/userguide/default-encryption-faq.html
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_bucket" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state_bucket.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Versioning configuration for the S3 bucket
resource "aws_s3_bucket_versioning" "terraform_state_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Bucket policy to restrict access to specific IAM roles and enforce secure transport
resource "aws_s3_bucket_policy" "terraform_state_bucket" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.terraform_state_bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.terraform_state_bucket.id}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            data.aws_iam_role.terraform_state_sso_principal_arn.arn
          ]
        }
        Action = "s3:*"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.terraform_state_bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.terraform_state_bucket.id}/*"
        ]
      }
    ]
  })
}

# DynamoDB table for Terraform state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = var.terraform_state_dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = var.terraform_state_dynamodb_table_name
  }
}
