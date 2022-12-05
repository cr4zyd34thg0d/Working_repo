data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_canonical_user_id" "current_user" {}

// Global IAM role for AutomationAssumeRole
data "aws_iam_role" "automation_assume_role" {
  name = "AWSConfigRemediation"
}

##############################
# LAMBDA ASSUME ROLE QUERIES #
##############################
data "aws_iam_role" "ami_public_check_lambda_role" {
  name = "ami-public-check-lambda-role"
}

data "aws_iam_role" "cloudwatch_loggroup_retention_remediation_lambda_role" {
  name = "cloudwatch-loggroup-retention-remediation-lambda-role"
}

data "aws_iam_role" "ebs_public_snapshot_remediation_lambda_role" {
  name = "ebs-public-snapshot-remediation-lambda-role"
}

data "aws_iam_role" "ami_public_remediation_lambda_role" {
  name = "ami-public-remediation-lambda-role"
}

data "aws_iam_role" "nacls_unrestricted_remediation_lambda_role" {
  name = "nacls-unrestricted-remediation-lambda-role"
}

# data "aws_iam_role" "ami_approved_by_tag_remediation_lambda_role" {
#   name = "ami-approved-by-tag-remediation-lambda-role"
# }

# data "aws_iam_role" "aurora_pitr_remediation_lambda_role" {
#   name = "aurora-pitr-remediation-lambda-role"
# }