resource "aws_config_configuration_recorder" "recorder" {
  name     = var.config_recorder_name
  role_arn = aws_iam_role.config_role.arn
}

resource "aws_config_configuration_recorder_status" "recorder" {
  count      = var.enable_config_recorder ? 1 : 0
  name       = var.config_recorder_name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.delivery]
}

resource "aws_iam_role" "config_role" {
  name               = var.config_role_name
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ""
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "config_rule" {
  name = var.config_name
  role = aws_iam_role.config_role.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "config:*",
        "s3:*",
        "cloudtrail:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    }
  ]
}
POLICY
}