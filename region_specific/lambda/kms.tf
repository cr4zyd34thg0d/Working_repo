# resource "aws_kms_key" "custom-lambda-remediation-key" {
#   description = "Key used for encrypting Custom AWS Config Remediation Lambdas."
#   policy      = data.aws_iam_policy_document.key_policy.json
# }

# resource "aws_kms_alias" "custom-lambda-remediation-key" {
#   name          = "alias/custom-lambda-remediation-key"
#   target_key_id = aws_kms_key.prototype_architecture_key.key_id
# }

# data "aws_iam_policy_document" "key_policy" {
#   statement {
#     actions = ["kms:*"]

#     resources = ["*"]

#     principals {
#       type        = "Service"
#       identifiers = ["lambda.amazonaws.com"]
#     }

#     principals {
#       type        = "AWS"
#       identifiers = [
#         aws_iam_role.cloudwatch_loggroup_retention_remediation_role.arn,
#       ]
#     }
#   }
# }