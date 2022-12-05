variable "region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "cw_retention_remediation_lambda_arn" {
  type = string
}

variable "ebs_public_snapshot_remediation_lambda_arn" {
  type = string
}

variable "ami_public_remediation_lambda_arn" {
  type = string
}

variable "nalcs_unrestricted_remediation_lambda_arn" {
  type = string
}

# variable "aurora_pitr_remediation_lambda_arn" {
#   type = string
# }

# variable "ec2_ssm_lambda_arn" {
#   type = string
# }

# variable "ami_approved_by_tag_lambda_arn" {
#   type = string
# }