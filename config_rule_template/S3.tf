data "aws_canonical_user_id" "current_user" {
}

variable "account_prefix" {}
variable "region_shortcode" {}
variable "environment" {}

resource "aws_s3_bucket" "terraform-state" {
  bucket        = "adc-sre-terraform-state-${var.region_shortcode}-${var.account_prefix}"
  force_destroy = "false"

  tags = {
    Name        = "adc-sre-terraform-state-${var.region_shortcode}-${var.account_prefix}"
    Environment = var.environment
    Owner       = "email"
    Department  = "SRE"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform-state" {
  bucket = aws_s3_bucket.terraform-state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_bucket_encryption" {
  bucket = aws_s3_bucket.terraform-state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "terraform_bucket_versioning" {
  bucket = aws_s3_bucket.terraform-state.id
  versioning_configuration {
    status = "Enabled"
  }
}

