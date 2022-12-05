resource "aws_config_config_rule" "config_rule" {
  name             = var.config_rule_name
  description      = var.config_rule_description
  input_parameters = var.config_rule_input_parameters

  source {
    owner             = var.config_rule_type
    source_identifier = var.config_rule_source

    dynamic "source_detail" {
      for_each = var.config_rule_type != "AWS" ? [1] : []
      content {
        message_type                = "ScheduledNotification"
        maximum_execution_frequency = "TwentyFour_Hours"
      }
    }
  }
}

resource "aws_config_remediation_configuration" "config_auto" {
  depends_on = [aws_config_config_rule.config_rule]

  count = var.create_remediation ? 1 : 0

  config_rule_name = var.config_rule_name
  resource_type    = var.remediation_resource_type
  target_type      = var.remediation_target_type
  target_id        = var.remediation_target_id

  dynamic "parameter" {
    for_each = var.remediation_parameters
    content {
      name           = parameter.value["name"]
      static_value   = parameter.value["value"] != "RESOURCE_ID" ? parameter.value["value"] : null
      resource_value = parameter.value["value"] == "RESOURCE_ID" ? parameter.value["value"] : null // parameter.value.value
    }
  }

  automatic                  = true
  maximum_automatic_attempts = 5
  retry_attempt_seconds      = 60

  execution_controls {
    ssm_controls {
      concurrent_execution_rate_percentage = 25
      error_percentage                     = 20
    }
  }
}

########################################################################################
# HISTORICAL RESOURCES FOR REFERENCE | NO LONGER NEEDED DUE TO SECURITY HUB DEPLOYMENT #
########################################################################################

# resource "aws_config_configuration_recorder" "recorder" {
#   name     = var.config_recorder_name
#   role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/auction-config-role"
# }

# resource "aws_config_configuration_recorder_status" "recorder" {
#   count      = var.enable_config_recorder ? 1 : 0
#   name       = var.config_recorder_name
#   is_enabled = true
#   depends_on = [aws_config_delivery_channel.delivery]
# }

# resource "aws_config_delivery_channel" "delivery" {
#   count = var.enable_config_recorder ? 1 : 0

#   name           = var.config_name
#   s3_bucket_name = var.config_logs_bucket

#   snapshot_delivery_properties {
#     delivery_frequency = var.config_delivery_frequency
#   }

#   # depends_on = [aws_config_configuration_recorder.recorder]
# }
