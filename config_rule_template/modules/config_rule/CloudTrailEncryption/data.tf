data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_s3_bucket" "selected" {
  bucket = var.config_logs_bucket #Update with bucket for logs
}
