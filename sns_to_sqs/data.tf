data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_organizations_organization" "org" {}

data "aws_iam_policy_document" "terraform_queue" {
  statement {
    sid    = "OwnerStatementForSQS"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["SQS:*"]
    resources = ["arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.terraform_queue_name}"]
  }

  statement {
    sid    = "TopicSubscriptionToSQS"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]

    }
    actions = [
      "SQS:SendMessage"
    ]
    resources = ["arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.terraform_queue_name}"]
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.sns_topic_name}"]
    }
  }
}