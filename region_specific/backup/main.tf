
# resource "aws_backup_vault" "config_rds_emergency_backup_vault" {
#   name        = "config-rds-emergency-backup-vault"
#   kms_key_arn = aws_kms_key.config_rds_emergency_backup_vault_key.arn
# }

# resource "aws_kms_key" "config_rds_emergency_backup_vault_key" {
#   description = "Key used for encrypting Custom AWS Config Remediation Lambdas."
#   policy      = data.aws_iam_policy_document.key_policy.json
# }

# resource "aws_kms_alias" "custom-lambda-remediation-key" {
#   name          = "alias/config-rds-emergency-backup-vault-key"
#   target_key_id = aws_kms_key.config_rds_emergency_backup_vault_key.key_id
# }

# data "aws_iam_policy_document" "key_policy" {
#   statement {
#     actions = ["kms:*"]

#     resources = ["*"]

#     principals {
#       type        = "Service"
#       identifiers = ["lambda.amazonaws.com","backup.amazonaws.com"]
#     }

#     principals {
#       type        = "AWS"
#       identifiers = [
#         data.aws_iam_role.aurora_pitr_remediation_lambda_role.arn
#       ]
#     }
#   }
# }