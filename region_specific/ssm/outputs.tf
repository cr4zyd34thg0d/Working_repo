output "cloudwatch_loggroup_retention_remediation_automation" {
  value = aws_ssm_document.cloudwatch_loggroup_retention_remediation_automation
}

output "ssm_public_sharing_remediation" {
  value = aws_ssm_document.ssm_public_sharing_remediation
}

output "ebs_snapshot_public_remediation" {
  value = aws_ssm_document.ebs_snapshot_public_remediation
}

output "ami_public_remediation" {
  value = aws_ssm_document.ami_public_remediation
}

output "nacls_unrestricted_remediation" {
  value = aws_ssm_document.nacls_unrestricted_remediation
}


# output "aurora_pitr_remediation" {
#   value = aws_ssm_document.aurora_has_recovery_point_remediation
# }

# output "ec2_ssm_remediation" {
#   value = aws_ssm_document.ec2_ssm_remediation
# }

# AWSS-19
# output "ami_approved_by_tag_remediation" {
#   value = aws_ssm_document.ami_approved_by_tag_remediation
# }