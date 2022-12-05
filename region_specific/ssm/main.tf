resource "aws_ssm_document" "cloudwatch_loggroup_retention_remediation_automation" {
  name          = "CloudWatchLogGroupRetentionRemediation"
  document_type = "Automation"

  content = templatefile("${path.module}/ssm_docs/cloudwatch_loggroup_retention_remediation_lambda_invoke.json.tpl", { CloudWatchLogGroupRetentionRemediationLambda = var.cw_retention_remediation_lambda_arn })
}

resource "aws_ssm_document" "ssm_public_sharing_remediation" {
  name          = "SSMPublicSharingRemediation"
  document_type = "Automation"

  content = templatefile("${path.module}/ssm_docs/ssm_public_sharing_remediation.json.tpl", { region = var.region })
}

resource "aws_ssm_document" "ebs_snapshot_public_remediation" {
  name          = "EBSPublicSnapshotRemediation"
  document_type = "Automation"

  content = templatefile("${path.module}/ssm_docs/ebs_snapshot_not_public_remediation_lambda_invoke.json.tpl", { EBSPublicSnapshotRemediationLambda = var.ebs_public_snapshot_remediation_lambda_arn })
}

resource "aws_ssm_document" "ami_public_remediation" {
  name          = "AMIPublicSnapshotRemediation"
  document_type = "Automation"

  content = templatefile("${path.module}/ssm_docs/ami_public_remediation_lambda_invoke.json.tpl", { AMIPublicRemediationLambda = var.ami_public_remediation_lambda_arn })
}

resource "aws_ssm_document" "nacls_unrestricted_remediation" {
  name          = "NACLSUnrestrcitedRemediation"
  document_type = "Automation"

  content = templatefile("${path.module}/ssm_docs/nacls_unrestricted_remediation_lambda_invoke.json.tpl", { NACLSUnrestrictedRemediationLambda = var.nalcs_unrestricted_remediation_lambda_arn })
}

# resource "aws_ssm_document" "aurora_has_recovery_point_remediation" {
#   name          = "AuroraBackupRecoveryPointCreatedRemediation"
#   document_type = "Automation"

#   content = templatefile("${path.module}/ssm_docs/aurora_has_point_in_time_backup_remediation.json.tpl", { AuroraRecoveryPointRemediationLambda = var.aurora_pitr_remediation_lambda_arn })
# }


# AWSS-30. Commented out due to Auction.com not using SSM as of Nov/16/22
# resource "aws_ssm_document" "ec2_ssm_remediation" {
#   name          = "EC2SSMRemediation"
#   document_type = "Automation"

#   content = templatefile("${path.module}/ssm_docs/ec2_ssm_remediation_lambda_invoke.json.tpl", { EC2SystemsManagerManagedRemediationLambda = var.ec2_ssm_lambda_arn })
# }

# AWSS-19
# resource "aws_ssm_document" "ami_approved_by_tag_remediation" {
#   name          = "AMIPublicSnapshotRemediation"
#   document_type = "Automation"

#   content = templatefile("${path.module}/ssm_docs/ami_approved_by_tags_remediation_lambda_invoke.json.tpl", { AMIApprovedByTagRemediationLambda = var.ami_approved_by_tag_lambda_arn })
# }

