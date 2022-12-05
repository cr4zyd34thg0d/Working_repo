output "cw_retention_lambda_arn" {
  value = aws_lambda_function.cloudwatch_loggroup_retention_remediation_lambda.arn
}

output "ami_public_check_lambda_arn" {
  value = aws_lambda_function.ami_public_remediation_lambda.arn
}

output "ebs_public_snapshot_lambda_arn" {
  value = aws_lambda_function.ebs_public_snapshot_remediation_lambda.arn
}

output "ami_public_remediation_lambda_arn" {
  value = aws_lambda_function.ami_public_check_lambda.arn
}

output "nalcs_unrestricted_remediation_lambda_arn" {
  value = aws_lambda_function.nacls_unrestricted_remediation_lambda.arn
}


# output "aurora_pitr_remediation_lambda_arn" {
#   value = aws_lambda_function.aurora_pitr_remediation_lambda.arn
# }

# output "EC2_SSM_Remediation_Lambda_Arn" {
#   value = aws_lambda_function.ec2_ssm_managed_remediation_lambda.arn
# }

# AWSS-329
# output "AMI_Approved_By_Tags_Remediation_Lambda_Arn" {
#   value = aws_lambda_function.ami_approved_by_tag_remediation_lambda.arn
# }

# AWSS-19
# output "Admin_Ports_Lambda_Arn" {
#   value = aws_lambda_function.admin_port_remediation_lambda.arn
# }