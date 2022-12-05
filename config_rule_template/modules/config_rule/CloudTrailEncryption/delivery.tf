resource "aws_config_delivery_channel" "delivery" {
  count = var.enable_config_recorder ? 1 : 0

  name           = var.config_name
  s3_bucket_name = var.config_logs_bucket

  snapshot_delivery_properties {
    delivery_frequency = var.config_delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}