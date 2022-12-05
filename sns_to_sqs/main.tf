resource "aws_sns_topic" "sns_topic" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "cloudtrail_topic_default" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = var.sns_protocol
  endpoint  = aws_sqs_queue.terraform_queue.arn
}

resource "aws_sqs_queue" "terraform_queue" {
  name = var.terraform_queue_name
}

resource "aws_sqs_queue_policy" "terraform_queue" {
  queue_url = aws_sqs_queue.terraform_queue.url
  policy    = data.aws_iam_policy_document.terraform_queue.json
}
