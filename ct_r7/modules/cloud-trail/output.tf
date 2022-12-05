output "s3_arn" {
  description = "S3 arn"
  value       = aws_s3_bucket.s3.arn
}

output "s3_id" {
  description = "S3 id"
  value       = aws_s3_bucket.s3.id
}

output "aws_cloudtrail_name" {
  description = "cloudtrail name"
  value       = aws_cloudtrail.CloudTrail.name
}

output "aws_cloudtrail_arn" {
  description = "cloudtrail arn"
  value       = aws_cloudtrail.CloudTrail.arn
}

output "aws_log_group_arn" {
  description = "The arn of the Log Goup"
  value       = aws_cloudwatch_log_group.log_group.arn
}

output "aws_sns_topic_arn" {
  description = "The arn of the snstopic"
  value       = aws_sns_topic.sns_topic.arn
}

output "aws_sqs_topic_arn" {
  description = "The arn of the snstopic"
  value       = aws_sqs_queue.terraform_queue.arn
}