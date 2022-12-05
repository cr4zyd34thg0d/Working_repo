resource "aws_cloudtrail" "CloudTrail" {
  name                       = var.trail_name
  is_multi_region_trail      = false
  s3_bucket_name             = aws_s3_bucket.s3.id
  is_organization_trail      = true
  enable_logging             = true
  enable_log_file_validation = true
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.log_group.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_role.arn
  sns_topic_name             = aws_sns_topic.sns_topic.arn

  event_selector {
    include_management_events = true
    read_write_type           = "All"
  }
  depends_on = [
    aws_sns_topic.sns_topic, aws_s3_bucket_policy.cloudtrail_bucket_policy
  ]
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = var.log_group_name
  retention_in_days = 90 #Adjust for the correct rention date
}