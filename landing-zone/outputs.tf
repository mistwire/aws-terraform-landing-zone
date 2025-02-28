output "budget_arn" {
  value = aws_budgets_budget.monthly_budget.arn
}

output "terraform_state_bucket_arn" {
  value = aws_s3_bucket.terraform_state_bucket.arn
}

output "kms_key_arn" {
  value = aws_kms_key.terraform_state_bucket.arn
}

output "kms_key_alias_arn" {
  value = aws_kms_alias.terraform_state_bucket.arn
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.terraform_state_lock.arn
}
