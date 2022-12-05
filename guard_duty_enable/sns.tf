module "SnsTopic" {
  source = "github.com/asecurecloud/tf_sns_email"

  display_name  = var.sns_topic_name
  email_address = "diffiede@amazon.com"
  stack_name    = "GuardDuty_findings_SNS"
}



data "aws_iam_policy_document" "topic-policy-PolicyForSnsTopic" {
  policy_id = "GuardDutySNS"

  statement {
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish",
      "SNS:Receive"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      module.SnsTopic.arn
    ]

    sid = "__default_statement_ID"
  }

  statement {
    actions = [
      "sns:Publish"
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [
      module.SnsTopic.arn
    ]

    sid = "GuardDutyDeployment"
  }
}