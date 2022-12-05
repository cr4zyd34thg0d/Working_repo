# resource "aws_config_remediation_configuration" "config_auto" {
#   config_rule_name = var.config_name
#   resource_type    = var.remediation_resource_type
#   target_type      = var.remediation_target_type
#   target_id        = var.remediation_target_id

#   depends_on = [
#     aws_config_config_rule.config_rule
#   ]

#   parameter {
#     name         = "TrailNames"
#     static_value = "RESOURCE_ID"
#   }

#   parameter {
#     name         = "KmsKeyID"
#     static_value = data.aws_s3_bucket.selected.arn
#   }

#   parameter {
#     name         = "AutomationAssumeRole"
#     static_value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:${var.config_role_name}"
#   }

#   automatic                  = true
#   maximum_automatic_attempts = 5
#   retry_attempt_seconds      = 60

#   execution_controls {
#     ssm_controls {
#       concurrent_execution_rate_percentage = 25
#       error_percentage                     = 20
#     }
#   }
# }
