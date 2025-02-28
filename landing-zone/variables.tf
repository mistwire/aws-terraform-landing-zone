variable "environment" {
  description = "The environment for the resources"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "budget_name" {
  description = "The name of the budget"
  type        = string
}

variable "budget_amount" {
  description = "The amount of the budget in USD"
  type        = number
}

variable "budget_time_unit" {
  description = "The time unit for the budget (MONTHLY, QUARTERLY, ANNUALLY)"
  type        = string
}

variable "budget_notification_email" {
  description = "The email address to send budget notifications"
  type        = string
}

variable "budget_threshold" {
  description = "The budget_threshold percentage for budget notifications"
  type        = number
}

variable "terraform_state_bucket_name" {
  description = "The name of the S3 bucket to store Terraform state"
  type        = string
}

variable "terraform_state_kms_alias_name" {
  description = "The name of the KMS alias"
  type        = string
}

variable "terraform_state_sso_principal_name" {
  description = "The SSO principal name for the IAM role (not the ARN)"
  type        = string
}

variable "terraform_state_dynamodb_table_name" {
  description = "The name of the DynamoDB table for Terraform state locking"
  type        = string
}

