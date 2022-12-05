output "aws_iam_role_arn" {
  value       = aws_iam_role.config_role.arn
  description = "config role ARN"
}

output "aws_iam_role_id" {
  value       = aws_iam_role.config_role.id
  description = "config role id"
}