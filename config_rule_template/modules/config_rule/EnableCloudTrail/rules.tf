resource "aws_config_config_rule" "config_rule" {
  count       = var.check_config ? 1 : 0
  name        = var.config_name
  description = "Checks the resources against the active rule."

  source {
    owner             = "AWS"
    source_identifier = var.rule_source
  }

  # tags = var.tags

  depends_on = [aws_config_configuration_recorder.recorder]
}