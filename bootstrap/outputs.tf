output "state_bucket_name" {
  value       = aws_s3_bucket.terraform_state.bucket
  description = "S3 bucket to use for Terraform remote state."
}
