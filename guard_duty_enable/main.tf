resource "aws_guardduty_detector" "GuardDuty" {
  enable = true
}

resource "aws_guardduty_organization_configuration" "GuardDutyconfig" {
  auto_enable = true
  detector_id = aws_guardduty_detector.GuardDuty.id

  datasources {
    s3_logs {
      auto_enable = true
    }
  }
}

resource "aws_cloudwatch_event_rule" "EventRule" {
  name          = "detect-guardduty-finding"
  description   = "A CloudWatch Event Rule that triggers on Amazon GuardDuty findings. The Event Rule can be used to trigger notifications or remediative actions using AWS Lambda."
  is_enabled    = true
  event_pattern = <<PATTERN
{
  "detail-type": [
    "GuardDuty Finding"
  ],
  "source": [
    "aws.guardduty"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "TargetForEventRule" {
  rule      = aws_cloudwatch_event_rule.EventRule.name
  target_id = "GuardDuty_finding"
  arn       = module.SnsTopic.arn
}

resource "aws_sns_topic_policy" "PolicyForSnsTopic" {
  arn    = module.SnsTopic.arn
  policy = data.aws_iam_policy_document.topic-policy-PolicyForSnsTopic.json
}

resource "aws_s3_bucket" "gd_bucket" {
  bucket        = "cloudtrail-awslogs-955305841756-w718ydjx-isengard-do-not-delete"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "gd_bucket_acl" {
  bucket = aws_s3_bucket.gd_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "gd_bucket_policy" {
  bucket = aws_s3_bucket.gd_bucket.id
  policy = data.aws_iam_policy_document.bucket_pol.json
}

resource "aws_kms_key" "gd_key" {
  description             = "Temporary key for AccTest of TF"
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.kms_pol.json
}

resource "aws_guardduty_publishing_destination" "test" {
  detector_id     = aws_guardduty_detector.GuardDuty.id
  destination_arn = aws_s3_bucket.gd_bucket.arn
  kms_key_arn     = aws_kms_key.gd_key.arn

  depends_on = [
    aws_s3_bucket_policy.gd_bucket_policy,
  ]
}