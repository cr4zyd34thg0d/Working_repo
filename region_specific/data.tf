data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_canonical_user_id" "current_user" {}

// Global IAM role for AutomationAssumeRole
data "aws_iam_role" "automation_assume_role" {
  name = "AWSConfigRemediation"
}
