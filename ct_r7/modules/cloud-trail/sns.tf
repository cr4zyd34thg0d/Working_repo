resource "aws_sns_topic" "sns_topic" {
  name   = var.sns_topic_name
  policy = data.aws_iam_policy_document.cloudtrail_alarm_policy.json
  tags   = merge(var.tags)
}

resource "aws_sns_topic_subscription" "cloudtrail_topic_default" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = var.sns_protocol
  endpoint  = aws_sqs_queue.terraform_queue.arn
}
