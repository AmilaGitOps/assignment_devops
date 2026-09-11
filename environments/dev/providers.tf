provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment_name
      ManagedBy   = "Terraform"
      Project     = var.app_stack_name
    }
  }
}
