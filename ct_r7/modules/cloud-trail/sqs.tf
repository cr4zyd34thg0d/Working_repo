resource "aws_sqs_queue" "terraform_queue" {
  name = var.terraform_queue_name
  tags = merge(var.tags)
}

resource "aws_sqs_queue_policy" "terraform_queue" {
  queue_url = aws_sqs_queue.terraform_queue.url
  policy    = data.aws_iam_policy_document.terraform_queue.json
}