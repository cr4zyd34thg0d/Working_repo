data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_organizations_organization" "org" {}

data "aws_iam_policy_document" "cloudtrail_alarm_policy" {
  statement {
    sid    = "ZuoraSNSTopicPolicy"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish",
      "SNS:Receive",
    ]

    resources = ["arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.sns_topic_name}"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = ["${data.aws_caller_identity.current.account_id}"]
    }
  }


  statement {
    sid    = "ZuoraSNSTopicCloudTrailPolicy"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "SNS:Publish",
    ]

    resources = ["arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.sns_topic_name}"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceARN"
      values   = ["arn:aws:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${var.trail_name}"]
    }
  }
}

data "aws_iam_policy_document" "cloudtrail_assume_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudtrail_policy" {
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogStream"]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*:log-stream:*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["logs:PutLogEvents"]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*:log-stream:*"]
  }
}

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