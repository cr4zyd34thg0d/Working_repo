locals {
  region = data.aws_region.current.name
  region_shorthands = {
    us-east-1 = "use1"
    us-east-2 = "use2"
    us-west-2 = "usw2"
  }
  region_shorthand  = local.region_shorthands[local.region]
  account_id        = data.aws_caller_identity.current.account_id
  account_last_four = substr(local.account_id, 8, 12)

  organization_log_group = "loggroupname"

  config_logs_bucket         = "config-bucket-${local.account_id}"
  elb_config_logs_bucket     = "elblogs-${local.account_last_four}-${local.region_shorthand}"
  automation_assume_role_arn = data.aws_iam_role.automation_assume_role.arn
  config_role_name           = "CONFIG-ROLE"
}

#################
# SSM DOCUMENTS #
#################
module "ssm_documents" {
  source                                     = "./ssm"
  region                                     = local.region
  account_id                                 = local.account_id
  cw_retention_remediation_lambda_arn        = module.rule_and_remediation_lambdas.cw_retention_lambda_arn
  ebs_public_snapshot_remediation_lambda_arn = module.rule_and_remediation_lambdas.ebs_public_snapshot_lambda_arn
  ami_public_remediation_lambda_arn          = module.rule_and_remediation_lambdas.ami_public_remediation_lambda_arn
  nalcs_unrestricted_remediation_lambda_arn  = module.rule_and_remediation_lambdas.nalcs_unrestricted_remediation_lambda_arn
  # aurora_pitr_remediation_lambda_arn         = module.rule_and_remediation_lambdas.aurora_pitr_remediation_lambda_arn
  # ec2_ssm_lambda_arn                = module.rule_and_remediation_lambdas.ec2_ssm_lambda_arn
  # ami_approved_by_tag_lambda_arn    = module.rule_and_remediation_lambdas.ami_approved_by_tag_lambda_arn
}

################################
# RULE AND REMEDIATION LAMBDAS #
################################
module "rule_and_remediation_lambdas" {
  source = "./lambda"

  # backup_vault_name = module.config_rds_emergency_backup_vault.name
}

####################################################
# BACKUP VAULT FOR  aurora_pitr_remediation_lambda #
####################################################
# module "rule_and_remediation_lambdas" {
#   source = "./backup"
# }

######################################################################
# CONFIG RULES & REMEDIATIONS                                        #
# * Some rules & remediations may be depedents on ./global resources #
######################################################################

module "s3_block_public_access_bucket_level_check_config_rule" {
  count = var.create_s3_block_public_access_bucket_level_check_config_rule ? 1 : 0

  source                  = "./config"
  config_rule_name        = "S3_Public_Access_Block_Bucket_Level_Check"
  config_rule_source      = "S3_BUCKET_LEVEL_PUBLIC_ACCESS_PROHIBITED"
  config_rule_description = "Config rule for checking if S3 public access is blocked at the bucket level."
  config_role_name        = local.config_role_name
  config_logs_bucket      = local.config_logs_bucket
}

module "s3_block_public_access_account_level_check_config_rule" {
  count = var.create_s3_block_public_access_account_level_check_config_rule ? 1 : 0

  source                  = "./config"
  config_rule_name        = "S3_Public_Access_Block_Account_Level_Check"
  config_rule_source      = "S3_ACCOUNT_LEVEL_PUBLIC_ACCESS_BLOCKS"
  config_rule_description = "Config rule for checking if S3 public access is blocked at the account level."
  config_role_name        = local.config_role_name
  config_logs_bucket      = local.config_logs_bucket
}

module "elb_log_enabled_check_config_rule" {
  count = var.create_elb_log_enabled_check_config_rule ? 1 : 0

  source                  = "./config"
  config_rule_name        = "ELB_Log_Enabled_Check"
  config_rule_source      = "ELB_LOGGING_ENABLED"
  config_rule_description = "Config rule for checking if ELB logging is enabled."
  config_role_name        = local.config_role_name
  config_logs_bucket      = local.config_logs_bucket

  create_remediation        = true
  remediation_resource_type = "AWS::ElasticLoadBalancing::LoadBalancer"
  remediation_target_type   = "SSM_DOCUMENT"
  remediation_target_id     = "AWSConfigRemediation-EnableLoggingForALBAndCLB"

  remediation_parameters = [
    {
      name  = "AutomationAssumeRole"
      value = local.automation_assume_role_arn
    },
    {
      name  = "LoadBalancerId"
      value = "RESOURCE_ID"
    },
    {
      name  = "S3BucketName"
      value = local.elb_config_logs_bucket
    }
  ]
}

module "vpc_sg_open_only_to_authorized_ports_check_config_rule" {
  count = var.create_vpc_sg_open_only_to_authorized_ports_check_config_rule ? 1 : 0

  source                       = "./config"
  config_rule_name             = "VPC_SG_Open_Only_to_Authorized_Ports_Check"
  config_rule_source           = "VPC_SG_OPEN_ONLY_TO_AUTHORIZED_PORTS"
  config_rule_description      = "Config rule for checking if VPC security groups rules allow un-authorized ports."
  config_rule_input_parameters = "{\"authorizedTcpPorts\":\"443\"}"
  config_role_name             = local.config_role_name
  config_logs_bucket           = local.config_logs_bucket
}

module "cw_loggroup_retention_period_check_config_rule" {
  count = var.create_cw_loggroup_retention_period_check_config_rule ? 1 : 0

  source                       = "./config"
  config_rule_name             = "CW_LogGroup_Retention_Period_Check"
  config_rule_source           = "CW_LOGGROUP_RETENTION_PERIOD_CHECK"
  config_rule_description      = "Config rule for checking if Cloudwatch log groups retention settings are >= 90. Uses custom remediation."
  config_rule_input_parameters = "{\"MinRetentionTime\":\"90\"}"
  config_role_name             = local.config_role_name
  config_logs_bucket           = local.config_logs_bucket

  create_remediation        = true
  remediation_resource_type = "AWS::Logs::LogGroup"
  remediation_target_type   = "SSM_DOCUMENT"
  remediation_target_id     = module.ssm_documents.cloudwatch_loggroup_retention_remediation_automation.name # "CloudWatchLogGroupRetentionRemediation"

  remediation_parameters = [
    {
      name  = "CloudWatchLogGroup"
      value = "RESOURCE_ID"
    },
    {
      name  = "AutomationAssumeRole"
      value = local.automation_assume_role_arn
    }
  ]
}

module "ebs_snapshot_public_restorable_check_config_rule" {
  count = var.create_ebs_snapshot_public_restorable_check_config_rule ? 1 : 0

  source                  = "./config"
  config_rule_name        = "EBS_Snapshot_Public_Restorable_Check"
  config_rule_source      = "EBS_SNAPSHOT_PUBLIC_RESTORABLE_CHECK"
  config_rule_description = "Config rule for checking if EBS snapshots/volumes are publicly available. Uses custom remediation."
  config_role_name        = local.config_role_name
  config_logs_bucket      = local.config_logs_bucket

  create_remediation        = true
  remediation_resource_type = null
  remediation_target_type   = "SSM_DOCUMENT"
  remediation_target_id     = module.ssm_documents.ebs_snapshot_public_remediation.name # "EBSPublicSnapshotRemediation"

  remediation_parameters = [
    {
      name  = "AutomationAssumeRole"
      value = local.automation_assume_role_arn
    }
  ]
}

module "secret_key_rotation_check_config_rule" {
  count = var.create_secret_key_rotation_check_config_rule ? 1 : 0

  source                  = "./config"
  config_rule_name        = "Secret_Key_Rotation_Check"
  config_rule_source      = "SECRETSMANAGER_ROTATION_ENABLED_CHECK"
  config_rule_description = "Config rule for checking if secret key rotation is enabled."
  config_role_name        = local.config_role_name
  config_logs_bucket      = local.config_logs_bucket
}

module "ec2_instance_no_public_ip" {
  count = var.create_ec2_instance_no_public_ip_config_rule ? 1 : 0

  source                  = "./config"
  config_rule_name        = "EC2_Instance_No_Public_IP"
  config_rule_source      = "EC2_INSTANCE_NO_PUBLIC_IP"
  config_rule_description = "Config rule for checking if a EC2 instances is attached to a public IP such as 0.0.0.0/0."
  config_role_name        = local.config_role_name
  config_logs_bucket      = local.config_logs_bucket
}

module "lambda_function_public_access_prohibited" {
  count = var.create_lambda_function_public_access_prohibited_config_rule ? 1 : 0

  source                  = "./config"
  config_rule_name        = "Lambda_Function_Public_Access_Prohibited"
  config_rule_source      = "LAMBDA_FUNCTION_PUBLIC_ACCESS_PROHIBITED"
  config_rule_description = "Config rule for checking if the AWS Lambda function policy attached to the lambda resource prohibites public access."
  config_role_name        = local.config_role_name
  config_logs_bucket      = local.config_logs_bucket
}

module "ec2_without_profile_check_config_rule" {
  count = var.create_ec2_without_profile_check_config_rule ? 1 : 0

  source                  = "./config"
  config_rule_name        = "EC2_Profile_Check"
  config_rule_source      = "EC2_INSTANCE_PROFILE_ATTACHED"
  config_rule_description = "Config Rule for checking if any EC2 instances exist without an instance profile attached."
  config_role_name        = local.config_role_name
  config_logs_bucket      = local.config_logs_bucket
}

module "ec2_ebs_encryption_by_default_check_config_rule" {
  count = var.create_ec2_ebs_encryption_by_default_check_config_rule ? 1 : 0

  source                  = "./config"
  config_rule_name        = "EC2_EBS_Encryption_by_Default_Check"
  config_rule_source      = "EC2_EBS_ENCRYPTION_BY_DEFAULT"
  config_rule_description = "Config rule for checking if EBS volume encryption is enabled (account level setting for new EBS volumes once enabled)."
  config_role_name        = local.config_role_name
  config_logs_bucket      = local.config_logs_bucket
}

module "secret_key_rotation_success_check_config_rule" {
  count = var.create_secret_key_rotation_success_check_config_rule ? 1 : 0

  source                  = "./config"
  config_rule_name        = "Secret_Key_Rotation_Success_Check"
  config_rule_source      = "SECRETSMANAGER_SCHEDULED_ROTATION_SUCCESS_CHECK"
  config_rule_description = "Config rule for checking if secret key rotation is successful or not."
  config_role_name        = local.config_role_name
  config_logs_bucket      = local.config_logs_bucket
}

module "ssm_document_public_check_config_rule" {
  count = var.create_ssm_document_public_check_config_rule ? 1 : 0

  source                  = "./config"
  config_rule_name        = "SSM_Document_Public_Check"
  config_rule_source      = "SSM_DOCUMENT_NOT_PUBLIC"
  config_rule_description = "Config rule for checking if an AWS Systems Manager SSM document is publicly available. Uses custom remediation."
  config_role_name        = local.config_role_name
  config_logs_bucket      = local.config_logs_bucket

  create_remediation        = true
  remediation_resource_type = null
  remediation_target_type   = "SSM_DOCUMENT"
  remediation_target_id     = module.ssm_documents.ssm_public_sharing_remediation.name # "SSMPublicSharingRemediation"

  remediation_parameters = [
    {
      name  = "AutomationAssumeRole"
      value = local.automation_assume_role_arn
    },
    {
      name  = "SSMDocumentID"
      value = "RESOURCE_ID"
    },
  ]
}

module "cloudtrail_security_trail_enabled_check_config_rule" {
  count = var.create_cloudtrail_security_trail_enabled_check_config_rule ? 1 : 0

  source                  = "./config"
  config_rule_name        = "Cloudtrail_Security_Trail_Enabled_Check"
  config_rule_source      = "CLOUDTRAIL_SECURITY_TRAIL_ENABLED"
  config_rule_description = "Config rule for checking if the Cloudtrail security trail is enabled."
  config_role_name        = local.config_role_name
  config_logs_bucket      = local.config_logs_bucket
}


# module "ec2_systems_manager_managed_check" {
#   count = var.create_ec2_systems_manager_managed_check_config_rule ? 1 : 0

#   source                  = "./config"
#   config_rule_name        = "EC2_Systems_Manager_Managed_Check"
#   config_rule_source      = "EC2_INSTANCE_MANAGED_BY_SSM"
#   config_rule_description = "Config rule for checking if EC2 instances are being managed by Systems Manager."
#   config_role_name        = local.config_role_name
#   config_logs_bucket      = local.config_logs_bucket

#   create_remediation        = true
#   remediation_resource_type = null
#   remediation_target_type   = "SSM_DOCUMENT"
#   remediation_target_id     = module.ssm_documents.ec2_ssm_remediation.name # "EC2SSMRemediation"

#   remediation_parameters = [
#     {
#       name  = "AutomationAssumeRole"
#       value = local.automation_assume_role_arn
#     },
#     {
#       name  = "InstanceID"
#       value = "RESOURCE_ID"
#     }
#   ]
# }

module "ami_public_check_config_rule" {
  count = var.create_ami_public_check_config_rule ? 1 : 0

  source                  = "./config"
  config_rule_name        = "AMI_Public_Image_Check"
  config_rule_source      = module.rule_and_remediation_lambdas.ami_public_check_lambda_arn
  config_rule_type        = "CUSTOM_LAMBDA"
  config_rule_description = "Config rule for checking if an AMI (Amazon Machine Image) is publicly available. Uses custom remediation."
  config_role_name        = local.config_role_name
  config_logs_bucket      = local.config_logs_bucket

  create_remediation        = true
  remediation_resource_type = null
  remediation_target_type   = "SSM_DOCUMENT"
  remediation_target_id     = module.ssm_documents.ami_public_remediation.name # "AMIPublicSnapshotRemediation"

  remediation_parameters = [
    {
      name  = "AutomationAssumeRole"
      value = local.automation_assume_role_arn
    },
    {
      name  = "AccountID"
      value = "RESOURCE_ID"
    }
  ]
}

module "acm_certificate_expiration_check_config_rule" {
  count = var.create_acm_certificate_expiration_check_config_rule ? 1 : 0

  source                  = "./config"
  config_rule_name        = "ACM_Certificate_Expiration_Check"
  config_rule_source      = "ACM_CERTIFICATE_EXPIRATION_CHECK"
  config_rule_description = "Config rule for checking if an ACM Certificate is about to expire."
  config_role_name        = local.config_role_name
  config_logs_bucket      = local.config_logs_bucket
}

module "iam_root_user_access_key_check_config_rule" {
  count = var.create_iam_root_user_access_key_check_config_rule ? 1 : 0

  source                  = "./config"
  config_rule_name        = "IAM_Root_User_Access_Key_Check"
  config_rule_source      = "IAM_ROOT_ACCESS_KEY_CHECK"
  config_rule_description = "Config rule for checking if the root user has any IAM access keys."
  config_role_name        = local.config_role_name
  config_logs_bucket      = local.config_logs_bucket
}

module "ami_has_approved_tags_check_config_rule" {
  count = var.create_ami_has_approved_tags_check_config_rule ? 1 : 0

  source                       = "./config"
  config_rule_name             = "AMI_Has_Approved_Tags_Check"
  config_rule_source           = "APPROVED_AMIS_BY_TAG"
  config_rule_description      = "Config rule for checking if all AMIs have required set of tags."
  config_rule_input_parameters = "{\"amisByTagKeyAndValue\":\"Owner,owner,Team,team,Department,department\"}"
  config_role_name             = local.config_role_name
  config_logs_bucket           = local.config_logs_bucket

  # AWSS-19
  # create_remediation        = true
  # remediation_resource_type = null
  # remediation_target_type   = "SSM_DOCUMENT"
  # remediation_target_id     = module.ssm_documents.ami_public_remediation.name

  # remediation_parameters = [
  #   {
  #     name  = "AutomationAssumeRole"
  #     value = local.automation_assume_role_arn
  #   },
  #   {
  #     name  = "AMI"
  #     value = "RESOURCE_ID"
  #   }
  # ]
}

module "restrict_incoming_traffic_config_rule" {
  count = var.create_restrict_incoming_traffic_config_rule ? 1 : 0

  source                       = "./config"
  config_rule_name             = "Restrict_Incoming_Traffic_Check"
  config_rule_source           = "RESTRICTED_INCOMING_TRAFFIC"
  config_rule_description      = "Config rule for checking if specific incomng traffic is being blocked."
  config_rule_input_parameters = "{\"blockedPort1\":\"20\",\"blockedPort2\":\"21\",\"blockedPort3\":\"3389\",\"blockedPort4\":\"3306\",\"blockedPort5\":\"4333\"}"
  config_role_name             = local.config_role_name
  config_logs_bucket           = local.config_logs_bucket
}

module "aurora_protected_by_backup_plan_config_rule" {
  count = var.create_aurora_protected_by_backup_plan_config_rule ? 1 : 0

  source                  = "./config"
  config_rule_name        = "Aurora_Protected_By_Backup_Plan_Check"
  config_rule_source      = "AURORA_RESOURCES_PROTECTED_BY_BACKUP_PLAN"
  config_rule_description = "Config rule for checking if Aurora DB clusters have a backup plan enabled."
  # config_rule_input_parameters = "{\"minRetentionDays\":\"1\"}"
  config_role_name   = local.config_role_name
  config_logs_bucket = local.config_logs_bucket
}

module "aurora_backup_has_recovery_point_config_rule" {
  count = var.create_aurora_backup_has_recovery_point_config_rule ? 1 : 0

  source                       = "./config"
  config_rule_name             = "Aurora_Backup_Has_Recovery_Point_Check"
  config_rule_source           = "AURORA_LAST_BACKUP_RECOVERY_POINT_CREATED"
  config_rule_description      = "Config rule for checking if Aurora DB clusters have a recovery point within the retention time."
  config_rule_input_parameters = "{\"recoveryPointAgeValue\":\"8\",\"recoveryPointAgeUnit\":\"days\"}"
  config_role_name             = local.config_role_name
  config_logs_bucket           = local.config_logs_bucket

  # AWSS-269
  # create_remediation        = true
  # remediation_resource_type = null
  # remediation_target_type   = "SSM_DOCUMENT"
  # remediation_target_id     = module.ssm_documents.aurora_pitr_remediation.name # AuroraBackupRecoveryPointCreatedRemediation

  # remediation_parameters = [
  #   {
  #     name  = "AutomationAssumeRole"
  #     value = local.automation_assume_role_arn
  #   },
  #   {
  #     name  = "DatabaseID"
  #     value = "RESOURCE_ID"
  #   }
  # ]
}

module "security_group_has_restricted_incoming_ssh_config_rule" {
  count = var.create_security_group_has_restricted_incoming_ssh_config_rule ? 1 : 0

  source                  = "./config"
  config_rule_name        = "Security_Group_Has_Restricted_SSH_Check"
  config_rule_source      = "INCOMING_SSH_DISABLED" # For 0.0.0.0/0
  config_rule_description = "Config rule for checking if Security Groups have unrestricted access to SSH (Non-Compliant if SSH is allowed from 0.0.0.0/0)."
  config_role_name        = local.config_role_name
  config_logs_bucket      = local.config_logs_bucket
}

module "nacl_has_restricted_incoming_ssh_config_rule" {
  count = var.create_nacl_has_restricted_incoming_ssh_config_rule ? 1 : 0

  source                  = "./config"
  config_rule_name        = "NACL_Has_Restricted_SSH_Check"
  config_rule_source      = "NACL_NO_UNRESTRICTED_SSH_RDP" # For 0.0.0.0/0
  config_rule_description = "Config rule for checking if NACLs have unrestricted access to SSH (Non-compliant if SSH is allowed from 0.0.0.0/0)."
  config_role_name        = local.config_role_name
  config_logs_bucket      = local.config_logs_bucket

  create_remediation        = local.region == "us-east-2" ? true : false
  remediation_resource_type = null
  remediation_target_type   = "SSM_DOCUMENT"
  remediation_target_id     = module.ssm_documents.nacls_unrestricted_remediation.name # "NACLsUnrestrictedRemediation"

  remediation_parameters = [
    {
      name  = "AutomationAssumeRole"
      value = local.automation_assume_role_arn
    },
    {
      name  = "NetworkAclID"
      value = "RESOURCE_ID"
    }
  ]
}

################################START###################################
###################----- EVENTBRIDGE NOTIFICATIONS ------###############
################################START###################################

module "sns_topic" {
  source     = "./sns-topic"
  sns_name   = "auction-config-rule-notifications-${local.account_id}"
  account_id = local.account_id
  protocol   = "email"
  email      = ["SRE-Alerts@auction.com", "it-secops@auction.com"] #Security Email address
}

module "sns_rds_topic" {
  source     = "./sns-topic"
  sns_name   = "auction-config-rule-rds-notifications-${local.account_id}"
  account_id = local.account_id
  protocol   = "email"
  email      = ["SRE-Alerts@auction.com", "it-secops@auction.com", "DL-IT-OPS-DBA@auction.com"] #Security Email address
}

# Eventbridge Rule and SNS ntification for restrict_incoming_traffic_config_rule - in place of automatic remediation
resource "aws_cloudwatch_event_rule" "restrict_incoming_traffic_config_rule_notification" {
  count = var.create_restrict_incoming_traffic_config_rule ? 1 : 0

  name        = "restrict-incoming-traffic-config-rule-notification"
  description = "Capture each Non-Compliant status change for the restrict-incoming-traffic-config-rule Config Rule and notify to SNS topic."

  event_pattern = <<EOF
{
  "source": [
    "aws.config"
  ],
  "detail-type": [
    "Config Rules Compliance Change"
  ],
  "detail": {
    "messageType": [
      "ComplianceChangeNotification"
    ],
    "configRuleName": [
      "Restrict_Incoming_Traffic_Check"
    ],
    "newEvaluationResult": {
      "complianceType": [
        "NON_COMPLIANT"
      ]
    }
  }
}
EOF
}


resource "aws_cloudwatch_event_target" "restrict_incoming_traffic_config_rule_notification-to_sns_notification" {
  count = var.create_restrict_incoming_traffic_config_rule ? 1 : 0

  rule      = aws_cloudwatch_event_rule.restrict_incoming_traffic_config_rule_notification[0].name
  target_id = "SendToSNS"
  arn       = module.sns_topic.arn

  input_transformer {
    input_paths = {
      awsRegion : "$.detail.awsRegion",
      awsAccountId : "$.detail.awsAccountId",
      rule : "$.detail.configRuleName",
      time : "$.detail.newEvaluationResult.resultRecordedTime"
    }
    input_template = "\"On <time> AWS Config rule <rule> evaluated in the account <awsAccountId> region <awsRegion> as NON_COMPLIANT\""
  }
}

# Eventbridge Rule and SNS ntification for aurora_protected_by_backup_plan_config_rule - in place of automatic remediation
resource "aws_cloudwatch_event_rule" "aurora_protected_by_backup_plan_config_rule_notification" {
  count = var.create_aurora_protected_by_backup_plan_config_rule ? 1 : 0

  name        = "aurora-protected-by-backup-plan-config-rule-notification"
  description = "Capture each Non-Compliant status change for the aurora-protected-by-backup-plan-config-rule Config Rule and notify to SNS topic."

  event_pattern = <<EOF
{
  "source": [
    "aws.config"
  ],
  "detail-type": [
    "Config Rules Compliance Change"
  ],
  "detail": {
    "messageType": [
      "ComplianceChangeNotification"
    ],
    "configRuleName": [
      "Aurora_Protected_By_Backup_Plan_Check"
    ],
    "newEvaluationResult": {
      "complianceType": [
        "NON_COMPLIANT"
      ]
    }
  }
}
EOF
}


resource "aws_cloudwatch_event_target" "aurora_protected_by_backup_plan_config_rule_notification-to_sns_notification" {
  count = var.create_aurora_protected_by_backup_plan_config_rule ? 1 : 0

  rule      = aws_cloudwatch_event_rule.aurora_protected_by_backup_plan_config_rule_notification[0].name
  target_id = "SendToSNS"
  arn       = module.sns_rds_topic.arn

  input_transformer {
    input_paths = {
      awsRegion : "$.detail.awsRegion",
      awsAccountId : "$.detail.awsAccountId",
      rule : "$.detail.configRuleName",
      time : "$.detail.newEvaluationResult.resultRecordedTime"
    }
    input_template = "\"On <time> AWS Config rule <rule> evaluated in the account <awsAccountId> region <awsRegion> as NON_COMPLIANT\""
  }
}

# Eventbridge Rule and SNS ntification for aurora_backup_has_recovery_point_config_rule - in place of automatic remediation
resource "aws_cloudwatch_event_rule" "aurora_backup_has_recovery_point_config_rule_notification" {
  count = var.create_aurora_backup_has_recovery_point_config_rule ? 1 : 0

  name        = "aurora-backup-has-recovery-point-config-rule-notification"
  description = "Capture each Non-Compliant status change for the aurora-backup-has-recovery-point-config-rule Config Rule and notify to SNS topic."

  event_pattern = <<EOF
{
  "source": [
    "aws.config"
  ],
  "detail-type": [
    "Config Rules Compliance Change"
  ],
  "detail": {
    "messageType": [
      "ComplianceChangeNotification"
    ],
    "configRuleName": [
      "Aurora_Backup_Has_Recovery_Point_Check"
    ],
    "newEvaluationResult": {
      "complianceType": [
        "NON_COMPLIANT"
      ]
    }
  }
}
EOF
}


resource "aws_cloudwatch_event_target" "aurora_backup_has_recovery_point_config_rule_notification-to_sns_notification" {
  count = var.create_restrict_incoming_traffic_config_rule ? 1 : 0

  rule      = aws_cloudwatch_event_rule.aurora_backup_has_recovery_point_config_rule_notification[0].name
  target_id = "SendToSNS"
  arn       = module.sns_rds_topic.arn

  input_transformer {
    input_paths = {
      awsRegion : "$.detail.awsRegion",
      awsAccountId : "$.detail.awsAccountId",
      rule : "$.detail.configRuleName",
      time : "$.detail.newEvaluationResult.resultRecordedTime"
    }
    input_template = "\"On <time> AWS Config rule <rule> evaluated in the account <awsAccountId> region <awsRegion> as NON_COMPLIANT\""
  }
}
