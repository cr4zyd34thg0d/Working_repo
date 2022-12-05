# SNS Subscribed to SQS

Template for subscribing a SNS topic to SQS

## About This Module

This TF code subscribes a SNS topic to SQS

## Brief Description on Setup

- Checks for name of SNS or creates the SNS topic
- Creates a SQS
- Subscribes SNS to SQS


## How to Use This Module

- This module can be used in any AWS environment to subscribed SNS to SQS
- The account used to deploy this module should have rights to assume the right account to allow for creating services/objects.
- Must have a way to deploy Terraform code.
- Change the variables in the main.tf:
```

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


```
- Run `terraform init` and `terraform apply`
Follow prompts to deploy the IaC (Infrstructure as Code) to your AWS environment.

