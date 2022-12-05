locals {
  region     = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id
}

####################################
# AUTOMATION ASSUME ROLE RESOURCES #
####################################
data "aws_iam_policy_document" "config_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com", "ssm.amazonaws.com", "lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "config_assume_role" {
  name        = var.role_name
  description = "IAM Role for Config service to execute SSM documents."

  assume_role_policy = data.aws_iam_policy_document.config_assume_policy.json

}

resource "aws_iam_role_policy_attachment" "config_assume_policy-config_assume_role" {
  role       = aws_iam_role.config_assume_role.name
  policy_arn = aws_iam_policy.config_assume_policy.arn
}

resource "aws_iam_policy" "config_assume_policy" {
  name        = "config-assume-policy"
  path        = "/"
  description = "IAM Policy for Config service to execute SSM documents.."
  policy      = data.aws_iam_policy_document.config_assume_policy_document.json
}

data "aws_iam_policy_document" "config_assume_policy_document" {
  statement {
    actions = [
      "config:GetResourceConfigHistory",
      "config:GetComplianceDetailsByConfigRule",
      "config:PutEvaluations",
      "ec2:DescribeImages",
      "ec2:DescribeSnapshots",
      "ec2:ModifyImageAttribute",
      "ec2:ModifySnapshotAttribute",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "lambda:InvokeFunction",
      "logs:PutRetentionPolicy"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "ssm:StartAutomationExecution",
      "ssm:GetAutomationExecution",
      "ssm:UpdateServiceSetting",
      "ssm:ModifyDocumentPermission"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  # statement {
  #   actions   = [
  #     "sts:AssumeRole"
  #   ]
  #   effect    = "Allow"
  #   resources = ["*"]
  # }
}

#######################
# LAMBDA ASSUME ROLES #
#######################

// Re-use
data "aws_iam_policy_document" "lambda_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_backup_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "backup.amazonaws.com"]
    }
  }
}

#############################
# CUSTOM RULE LAMBDAS ROLES #
#############################
resource "aws_iam_role" "ami_public_check_lambda_role" {
  name        = "ami-public-check-lambda-role"
  description = "IAM Role for ami-public-check-lambda Lambda."

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "ami_public_check_lambda_policy-ami_public_check_lambda_role" {
  role       = aws_iam_role.ami_public_check_lambda_role.name
  policy_arn = aws_iam_policy.ami_public_check_lambda_policy.arn
}

resource "aws_iam_policy" "ami_public_check_lambda_policy" {
  name        = "ami-public-check-lambda-policy"
  path        = "/"
  description = "IAM Policy for ami-public-check-lambda Lambda."
  policy      = data.aws_iam_policy_document.ami_public_check_lambda_policy_document.json
}

data "aws_iam_policy_document" "ami_public_check_lambda_policy_document" {
  # sts_client.assume_role
  statement {
    actions = [
      "config:GetComplianceDetailsByConfigRule",
      "config:GetResourceConfigHistory",
      "config:PutEvaluations",
      "ec2:DescribeImages"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect    = "Allow"
    resources = [aws_iam_role.config_assume_role.arn]
  }

  #   statement {
  #     effect = "Allow"
  #     actions = [
  #       "kms:CreateGrant",
  #       "kms:Decrypt",
  #       "kms:Encrypt",
  #       "kms:ListAliases",
  #     ]
  #     resources = [
  #       aws_kms_key.custom-lambda-remediation-key.arn,
  #     ]
  #   }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup"
    ]
    resources = ["*"]
  }
}

############################
# REMEDIATION LAMBDA ROLES #
############################

resource "aws_iam_role" "cloudwatch_loggroup_retention_remediation_lambda_role" {
  name        = "cloudwatch-loggroup-retention-remediation-lambda-role"
  description = "IAM Role for cloudwatch-loggroup-retention-remediation-lambda Lambda."

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch_loggroup_retention_remediation_lambda_policy-cloudwatch_loggroup_retention_remediation_lambda_role" {
  role       = aws_iam_role.cloudwatch_loggroup_retention_remediation_lambda_role.name
  policy_arn = aws_iam_policy.cloudwatch_loggroup_retention_remediation_lambda_policy.arn
}

resource "aws_iam_policy" "cloudwatch_loggroup_retention_remediation_lambda_policy" {
  name        = "cloudwatch-loggroup-retention-remediation-lambda-policy"
  path        = "/"
  description = "IAM Policy for cloudwatch-loggroup-retention-remediation-lambda Lambda."
  policy      = data.aws_iam_policy_document.cloudwatch_loggroup_retention_remediation_lambda_policy_document.json
}

data "aws_iam_policy_document" "cloudwatch_loggroup_retention_remediation_lambda_policy_document" {
  statement {
    actions   = ["logs:PutRetentionPolicy"]
    effect    = "Allow"
    resources = ["*"]
  }

  #   statement {
  #     effect = "Allow"
  #     actions = [
  #       "kms:CreateGrant",
  #       "kms:Decrypt",
  #       "kms:Encrypt",
  #       "kms:ListAliases",
  #     ]
  #     resources = [
  #       aws_kms_key.custom-lambda-remediation-key.arn,
  #     ]
  #   }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup"
    ]
    resources = ["*"]
  }
}

#######################################################

resource "aws_iam_role" "ebs_public_snapshot_remediation_lambda_role" {
  name        = "ebs-public-snapshot-remediation-lambda-role"
  description = "IAM Role for ebs-public-snapshot-remediation-lambda Lambda."

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "ebs_public_snapshot_remediation_lambda_policy-ebs_public_snapshot_remediation_lambda_role" {
  role       = aws_iam_role.ebs_public_snapshot_remediation_lambda_role.name
  policy_arn = aws_iam_policy.ebs_public_snapshot_remediation_lambda_policy.arn
}

resource "aws_iam_policy" "ebs_public_snapshot_remediation_lambda_policy" {
  name        = "ebs-public-snapshot-remediation-lambda-policy"
  path        = "/"
  description = "IAM Policy for ebs-public-snapshot-remediation-lambda Lambda."
  policy      = data.aws_iam_policy_document.ebs_public_snapshot_remediation_lambda_policy_document.json
}

data "aws_iam_policy_document" "ebs_public_snapshot_remediation_lambda_policy_document" {
  statement {
    actions   = ["ec2:ModifySnapshotAttribute", "ec2:DescribeSnapshots"]
    effect    = "Allow"
    resources = ["*"]
  }

  #   statement {
  #     effect = "Allow"
  #     actions = [
  #       "kms:CreateGrant",
  #       "kms:Decrypt",
  #       "kms:Encrypt",
  #       "kms:ListAliases",
  #     ]
  #     resources = [
  #       aws_kms_key.custom-lambda-remediation-key.arn,
  #     ]
  #   }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup"
    ]
    resources = ["*"]
  }
}

#######################################################

resource "aws_iam_role" "ami_public_remediation_lambda_role" {
  name        = "ami-public-remediation-lambda-role"
  description = "IAM Role for ami-public-remediation-lambda Lambda."

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "ami_public_remediation_lambda_policy-ami_public_remediation_lambda_role" {
  role       = aws_iam_role.ami_public_remediation_lambda_role.name
  policy_arn = aws_iam_policy.ami_public_remediation_lambda_policy.arn
}

resource "aws_iam_policy" "ami_public_remediation_lambda_policy" {
  name        = "ami-public-remediation-lambda-policy"
  path        = "/"
  description = "IAM Policy for ami-public-remediation-lambda Lambda."
  policy      = data.aws_iam_policy_document.ami_public_remediation_lambda_policy_document.json
}

data "aws_iam_policy_document" "ami_public_remediation_lambda_policy_document" {

  # config.get_resource_config_history
  # config.get_compliance_details_by_config_rule
  # config.put_evaluations
  # ec2.describe_images
  # sts_client.assume_role
  statement {
    actions   = ["ec2:ModifyImageAttribute", "ec2:DescribeImages"]
    effect    = "Allow"
    resources = ["*"]
  }

  #   statement {
  #     effect = "Allow"
  #     actions = [
  #       "kms:CreateGrant",
  #       "kms:Decrypt",
  #       "kms:Encrypt",
  #       "kms:ListAliases",
  #     ]
  #     resources = [
  #       aws_kms_key.custom-lambda-remediation-key.arn,
  #     ]
  #   }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup"
    ]
    resources = ["*"]
  }
}

#######################################################

resource "aws_iam_role" "nacls_unrestricted_remediation_lambda_role" {
  name        = "nacls-unrestricted-remediation-lambda-role"
  description = "IAM Role for nacls-unrestricted-remediation-lambda Lambda."

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "nacls_unrestricted_remediation_lambda_policy-nacls_unrestricted_remediation_lambda_role" {
  role       = aws_iam_role.nacls_unrestricted_remediation_lambda_role.name
  policy_arn = aws_iam_policy.nacls_unrestricted_remediation_lambda_policy.arn
}

resource "aws_iam_policy" "nacls_unrestricted_remediation_lambda_policy" {
  name        = "nacls-unrestricted-remediation-lambda-policy"
  path        = "/"
  description = "IAM Policy for nacls-unrestricted-remediation-lambda Lambda."
  policy      = data.aws_iam_policy_document.nacls_unrestricted_remediation_lambda_policy_document.json
}

data "aws_iam_policy_document" "nacls_unrestricted_remediation_lambda_policy_document" {
  statement {
    actions   = ["ec2:DeleteNetworkAclEntry", "ec2:DescribeNetworkAcls", "ec2:ReplaceNetworkAclEntry"]
    effect    = "Allow"
    resources = ["*"]
  }

  #   statement {
  #     effect = "Allow"
  #     actions = [
  #       "kms:CreateGrant",
  #       "kms:Decrypt",
  #       "kms:Encrypt",
  #       "kms:ListAliases",
  #     ]
  #     resources = [
  #       aws_kms_key.custom-lambda-remediation-key.arn,
  #     ]
  #   }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup"
    ]
    resources = ["*"]
  }
}

#######################################################

# AWSS-329
# resource "aws_iam_role" "ami_approved_by_tag_remediation_lambda_role" {
#   name        = "ami-approved-by-tag-remediation-lambda-role"
#   description = "IAM Role for ami-approved-by-tag-remediation-lambda Lambda."

#   assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
# }

# resource "aws_iam_role_policy_attachment" "ami_approved_by_tag_remediation_lambda_policy-ami_approved_by_tag_remediation_lambda_role" {
#   role       = aws_iam_role.ami_approved_by_tag_remediation_lambda_role.name
#   policy_arn = aws_iam_policy.ami_approved_by_tag_remediation_lambda_policy.arn
# }

# resource "aws_iam_policy" "ami_approved_by_tag_remediation_lambda_policy" {
#   name        = "ami-approved-by-tag-remediation-lambda-policy"
#   path        = "/"
#   description = "IAM Policy for ami-approved-by-tag-remediation-lambda Lambda."
#   policy      = data.aws_iam_policy_document.ami_approved_by_tag_remediation_lambda_policy_document.json
# }

# data "aws_iam_policy_document" "ami_approved_by_tag_remediation_lambda_policy_document" {

#   # config.get_resource_config_history
#   # config.get_compliance_details_by_config_rule
#   # config.put_evaluations
#   # ec2.describe_images
#   # sts_client.assume_role
#   statement {
#     actions   = ["ec2:TerminateInstances"]
#     effect    = "Allow"
#     resources = ["*"]
#   }

#   #   statement {
#   #     effect = "Allow"
#   #     actions = [
#   #       "kms:CreateGrant",
#   #       "kms:Decrypt",
#   #       "kms:Encrypt",
#   #       "kms:ListAliases",
#   #     ]
#   #     resources = [
#   #       aws_kms_key.custom-lambda-remediation-key.arn,
#   #     ]
#   #   }

#   statement {
#     effect = "Allow"
#     actions = [
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#       "logs:CreateLogGroup"
#     ]
#     resources = ["*"]
#   }
# }

#######################################################

# AWSS-269
# resource "aws_iam_role" "aurora_pitr_remediation_lambda_role" {
#   name        = "aurora-pitr-remediation-lambda-role"
#   description = "IAM Role for aurora-pitr-remediation-lambda Lambda."

#   assume_role_policy = data.aws_iam_policy_document.lambda_backup_assume_policy.json
# }

# resource "aws_iam_role_policy_attachment" "aurora_pitr_remediation_lambda_policy-aurora_pitr_remediation_lambda_role" {
#   role       = aws_iam_role.aurora_pitr_remediation_lambda_role.name
#   policy_arn = aws_iam_policy.aurora_pitr_remediation_lambda_policy.arn
# }

# resource "aws_iam_policy" "aurora_pitr_remediation_lambda_policy" {
#   name        = "aurora-pitr-remediation-lambda-policy"
#   path        = "/"
#   description = "IAM Policy for aurora-pitr-remediation-lambda Lambda."
#   policy      = data.aws_iam_policy_document.aurora_pitr_remediation_lambda_policy_document.json
# }

# data "aws_iam_policy_document" "aurora_pitr_remediation_lambda_policy_document" {
#   statement {
#     actions   = ["backup:StartBackupJob", "kms:Encrypt", "rds:DescribeDBClusters"]
#     effect    = "Allow"
#     resources = ["*"]
#   }

#   statement {
#     actions   = ["iam:PassRole"]
#     effect    = "Allow"
#     resources = ["arn:aws:iam::${local.account_id}:role/aurora-pitr-remediation-lambda-role"]
#   }

#   #   statement {
#   #     effect = "Allow"
#   #     actions = [
#   #       "kms:CreateGrant",
#   #       "kms:Decrypt",
#   #       "kms:Encrypt",
#   #       "kms:ListAliases",
#   #     ]
#   #     resources = [
#   #       aws_kms_key.custom-lambda-remediation-key.arn,
#   #     ]
#   #   }

#   statement {
#     effect = "Allow"
#     actions = [
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#       "logs:CreateLogGroup"
#     ]
#     resources = ["*"]
#   }
# }

#######################################################

# AWSS-30. Commented out due to Auction.com not using SSM as of Nov/16/22
# resource "aws_iam_role" "ec2_ssm_managed_remediation_lambda_role" {
#   name        = "ec2-ssm-managed-remediation-lambda-role"
#   description = "IAM Role for ec2-ssm-managed-remediation-lambda-role Lambda."

#   assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
# }

# resource "aws_iam_role_policy_attachment" "ec2_ssm_managed_remediation_lambda_policy-ec2_ssm_managed_remediation_lambda_role" {
#   role       = aws_iam_role.ec2_ssm_managed_remediation_lambda_role.name
#   policy_arn = aws_iam_policy.ec2_ssm_managed_remediation_lambda_policy.arn
# }

# resource "aws_iam_policy" "ec2_ssm_managed_remediation_lambda_policy" {
#   name        = "ec2-ssm-managed-remediation-lambda-policy"
#   path        = "/"
#   description = "IAM Policy for ec2-ssm-managed-remediation-lambda-role Lambda."
#   policy      = data.aws_iam_policy_document.ec2_ssm_managed_remediation_lambda_policy_document.json
# }

# data "aws_iam_policy_document" "ec2_ssm_managed_remediation_lambda_policy_document" {
#   statement {
#     actions   = ["ec2:TerminateInstances"]
#     effect    = "Allow"
#     resources = ["*"]
#   }

#   #   statement {
#   #     effect = "Allow"
#   #     actions = [
#   #       "kms:CreateGrant",
#   #       "kms:Decrypt",
#   #       "kms:Encrypt",
#   #       "kms:ListAliases",
#   #     ]
#   #     resources = [
#   #       aws_kms_key.custom-lambda-remediation-key.arn,
#   #     ]
#   #   }

#   statement {
#     effect = "Allow"
#     actions = [
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#       "logs:CreateLogGroup"
#     ]
#     resources = ["*"]
#   }
# }

#######################################################

# AWSS-19. Using SNS Notification instead of remediation
# resource "aws_iam_role" "admin_ports_remediation_lambda_role" {
#   name        = "admin-ports-remediation-lambda-role"
#   description = "IAM Role for admin-ports-remediation-lambda-role Lambda."

#   assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
# }

# resource "aws_iam_role_policy_attachment" "admin_ports_remediation_lambda_policy-admin_ports_remediation_lambda_role" {
#   role       = aws_iam_role.admin_ports_remediation_lambda_role.name
#   policy_arn = aws_iam_policy.admin_ports_remediation_lambda_policy.arn
# }

# resource "aws_iam_policy" "admin_ports_remediation_lambda_policy" {
#   name        = "admin-ports-remediation-lambda-role-policy"
#   path        = "/"
#   description = "IAM Policy for admin-ports-remediation-lambda-role Lambda."
#   policy      = data.aws_iam_policy_document.admin_ports_remediation_lambda_policy_document.json
# }

# data "aws_iam_policy_document" "admin_ports_remediation_lambda_policy_document" {

#   # config.get_resource_config_history
#   # config.get_compliance_details_by_config_rule
#   # config.put_evaluations
#   # ec2.describe_images
#   # sts_client.assume_role
#   statement {
#     actions   = ["ec2:TerminateInstances"]
#     effect    = "Allow"
#     resources = ["*"]
#   }

#   #   statement {
#   #     effect = "Allow"
#   #     actions = [
#   #       "kms:CreateGrant",
#   #       "kms:Decrypt",
#   #       "kms:Encrypt",
#   #       "kms:ListAliases",
#   #     ]
#   #     resources = [
#   #       aws_kms_key.custom-lambda-remediation-key.arn,
#   #     ]
#   #   }

#   statement {
#     effect = "Allow"
#     actions = [
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#       "logs:CreateLogGroup"
#     ]
#     resources = ["*"]
#   }
# }

#######################################################