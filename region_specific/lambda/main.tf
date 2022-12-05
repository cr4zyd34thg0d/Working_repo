locals {
  automation_assume_role_arn = data.aws_iam_role.automation_assume_role.arn

  ami_public_check_lambda_role_arn                          = data.aws_iam_role.ami_public_check_lambda_role.arn
  cloudwatch_loggroup_retention_remediation_lambda_role_arn = data.aws_iam_role.cloudwatch_loggroup_retention_remediation_lambda_role.arn
  ebs_public_snapshot_remediation_lambda_role_arn           = data.aws_iam_role.ebs_public_snapshot_remediation_lambda_role.arn
  ami_public_remediation_lambda_role_arn                    = data.aws_iam_role.ami_public_remediation_lambda_role.arn
  nacls_unrestricted_remediation_lambda_role_arn            = data.aws_iam_role.nacls_unrestricted_remediation_lambda_role.arn
  # aurora_pitr_remediation_lambda_role_arn                   = data.aws_iam_role.aurora_pitr_remediation_lambda_role.arn

  region     = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id
}
#######################
# CUSTOM RULE LAMBDAS #
#######################
resource "aws_lambda_function" "ami_public_check_lambda" {
  filename      = "${path.module}/src/Rules/AMIPublicCheckRuleLambda/lambda_function.py.zip"
  function_name = "ami-public-check-lambda"
  description   = "Lambda for checking for public AMIs."
  role          = local.ami_public_check_lambda_role_arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = filebase64sha256("${path.module}/src/Rules/AMIPublicCheckRuleLambda/lambda_function.py.zip")

  runtime                        = "python3.9"
  memory_size                    = 256
  timeout                        = 120
  reserved_concurrent_executions = 10
}

resource "aws_lambda_permission" "ami_public_check_lambda-config_invoke" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ami_public_check_lambda.arn
  principal     = "config.amazonaws.com"
  statement_id  = "AllowExecutionFromConfig"
}

#######################
# REMEDIATION LAMBDAS #
#######################
resource "aws_lambda_function" "cloudwatch_loggroup_retention_remediation_lambda" {
  filename      = "${path.module}/src/Remediations/CloudWatchLogGroupRetentionRemediationLambda/lambda_function.py.zip"
  function_name = "cloudwatch-loggroup-retention-remediation-lambda"
  description   = "Lambda for remediating retention periods from Config to Cloudwatch Log Groups."
  role          = local.cloudwatch_loggroup_retention_remediation_lambda_role_arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = filebase64sha256("${path.module}/src/Remediations/CloudWatchLogGroupRetentionRemediationLambda/lambda_function.py.zip")

  runtime                        = "python3.9"
  memory_size                    = 256
  timeout                        = 120
  reserved_concurrent_executions = 10

  environment {
    variables = {
      RETENTION = 90
    }
  }
}

resource "aws_lambda_permission" "cloudwatch_loggroup_retention_remediation_lambda-config_invoke" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudwatch_loggroup_retention_remediation_lambda.arn
  principal     = "config.amazonaws.com"
  statement_id  = "AllowExecutionFromConfig"
}

resource "aws_lambda_function" "ebs_public_snapshot_remediation_lambda" {
  filename      = "${path.module}/src/Remediations/EBSPublicSnapshotRemediationLambda/lambda_function.py.zip"
  function_name = "ebs-public-snapshot-remediation-lambda"
  description   = "Lambda for remediating public EBS snapshots."
  role          = local.ebs_public_snapshot_remediation_lambda_role_arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = filebase64sha256("${path.module}/src/Remediations/EBSPublicSnapshotRemediationLambda/lambda_function.py.zip")

  runtime                        = "python3.9"
  memory_size                    = 256
  timeout                        = 120
  reserved_concurrent_executions = 10
}

resource "aws_lambda_permission" "ebs_public_snapshot_remediation_lambda-config_invoke" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ebs_public_snapshot_remediation_lambda.arn
  principal     = "config.amazonaws.com"
  statement_id  = "AllowExecutionFromConfig"
}

resource "aws_lambda_function" "ami_public_remediation_lambda" {
  filename      = "${path.module}/src/Remediations/AMIPublicCheckRemediationLambda/lambda_function.py.zip"
  function_name = "ami-public-remediation-lambda"
  description   = "Lambda for remediating public AMIs."
  role          = local.ami_public_remediation_lambda_role_arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = filebase64sha256("${path.module}/src/Remediations/AMIPublicCheckRemediationLambda/lambda_function.py.zip")

  runtime                        = "python3.9"
  memory_size                    = 256
  timeout                        = 120
  reserved_concurrent_executions = 10
}

resource "aws_lambda_permission" "ami_public_remediation_lambda-config_invoke" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ami_public_remediation_lambda.arn
  principal     = "config.amazonaws.com"
  statement_id  = "AllowExecutionFromConfig"
}

resource "aws_lambda_function" "nacls_unrestricted_remediation_lambda" {
  filename      = "${path.module}/src/Remediations/NACLsUnrestrictedRemediationLambda/lambda_function.py.zip"
  function_name = "nacls_unrestricted-remediation-lambda"
  description   = "Lambda for remediating ACLs that are misconfigured in relation to Auctions envirotnment us-east-2."
  role          = local.nacls_unrestricted_remediation_lambda_role_arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = filebase64sha256("${path.module}/src/Remediations/NACLsUnrestrictedRemediationLambda/lambda_function.py.zip")

  runtime                        = "python3.9"
  memory_size                    = 256
  timeout                        = 120
  reserved_concurrent_executions = 10
}

resource "aws_lambda_permission" "nacls_unrestricted_remediation_lambda-config_invoke" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.nacls_unrestricted_remediation_lambda.arn
  principal     = "config.amazonaws.com"
  statement_id  = "AllowExecutionFromConfig"
}

# AWSS-269
# resource "aws_lambda_function" "aurora_pitr_remediation_lambda" {
#   filename      = "${path.module}/src/Remediations/AuroraPointInTimeRecoveryRemediationLambda/lambda_function.py.zip"
#   function_name = "aurora-pitr-remediation-lambda"
#   description   = "Lambda for remediating Aurora clusters without Point In Time Recovery."
#   role          = local.aurora_pitr_remediation_lambda_role_arn
#   handler       = "lambda_function.lambda_handler"

#   source_code_hash = filebase64sha256("${path.module}/src/Remediations/AuroraPointInTimeRecoveryRemediationLambda/lambda_function.py.zip")

#   runtime     = "python3.9"
#   memory_size = 256
#   timeout     = 120

#   environment {
#     variables = {
#       BACKUP_VAULT    = var.backup_vault_name
#       BACKUP_IAM_ROLE = local.aurora_pitr_remediation_lambda_role_arn
#     }
#   }

# }

# resource "aws_lambda_permission" "aurora_pitr_remediation_lambda-config_invoke" {
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.aurora_pitr_remediation_lambda.arn
#   principal     = "config.amazonaws.com"
#   statement_id  = "AllowExecutionFromConfig"
# }

# AWSS-30. Commented out due to Auction.com not using SSM as of Nov/16/22
# resource "aws_lambda_function" "ec2_ssm_managed_remediation_lambda" {
#   filename      = "${path.module}/src/Remediations/EC2SystemsManagerManagedRemediation/lambda_function.py.zip"
#   function_name = "ec2-ssm-managed-remediation-lambda"
#   description   = "Lambda for remediating instances without SSM."
#   role          = aws_iam_role.ec2_ssm_managed_remediation_lambda_role.arn
#   handler       = "lambda_function.lambda_handler"

#   source_code_hash = filebase64sha256("${path.module}/src/Remediations/EC2SystemsManagerManagedRemediation/lambda_function.py.zip")

#   runtime     = "python3.9"
#   memory_size = 256
#   timeout     = 120
# }

# resource "aws_lambda_permission" "ec2_ssm_managed_remediation_lambda-config_invoke" {
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.ec2_ssm_managed_remediation_lambda.arn
#   principal     = "config.amazonaws.com"
#   statement_id  = "AllowExecutionFromConfig"
# }

# AWSS-329
# resource "aws_lambda_function" "ami_approved_by_tag_remediation_lambda" {
#   filename      = "${path.module}/src/Remediations/AMIApprovedByTagRemediationLambda/lambda_function.py.zip"
#   function_name = "ami-approved-by-tag-remediation-lambda"
#   description   = "Lambda for remediating instances without approved AMI tags."
#   role          = aws_iam_role.ami_approved_by_tag_remediation_lambda_role.arn
#   handler       = "lambda_function.lambda_handler"

#   source_code_hash = filebase64sha256("${path.module}/src/Remediations/AMIApprovedByTagRemediationLambda/lambda_function.py.zip")

#   runtime     = "python3.9"
#   memory_size = 256
#   timeout     = 120
# }

# resource "aws_lambda_permission" "ami_approved_by_tag_remediation_lambda-config_invoke" {
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.ami_approved_by_tag_remediation_lambda.arn
#   principal     = "config.amazonaws.com"
#   statement_id  = "AllowExecutionFromConfig"
# }
