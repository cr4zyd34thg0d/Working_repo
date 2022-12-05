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