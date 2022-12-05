############################################################# 
# Add ability to create or not create specific config rules #
############################################################# 
variable "create_s3_block_public_access_bucket_level_check_config_rule" {
  type    = bool
  default = true
}

variable "create_s3_block_public_access_account_level_check_config_rule" {
  type    = bool
  default = true
}

variable "create_elb_log_enabled_check_config_rule" {
  type    = bool
  default = true
}

variable "create_vpc_sg_open_only_to_authorized_ports_check_config_rule" {
  type    = bool
  default = true
}

variable "create_cw_loggroup_retention_period_check_config_rule" {
  type    = bool
  default = true
}

variable "create_ebs_snapshot_public_restorable_check_config_rule" {
  type    = bool
  default = true
}

variable "create_secret_key_rotation_check_config_rule" {
  type    = bool
  default = true
}

variable "create_ec2_without_profile_check_config_rule" {
  type    = bool
  default = true
}

variable "create_ec2_ebs_encryption_by_default_check_config_rule" {
  type    = bool
  default = true
}

variable "create_secret_key_rotation_success_check_config_rule" {
  type    = bool
  default = true
}

variable "create_ssm_document_public_check_config_rule" {
  type    = bool
  default = true
}

variable "create_cloudtrail_security_trail_enabled_check_config_rule" {
  type    = bool
  default = true
}

variable "create_ami_public_check_config_rule" {
  type    = bool
  default = true
}

variable "create_acm_certificate_expiration_check_config_rule" {
  type    = bool
  default = true
}

variable "create_iam_root_user_access_key_check_config_rule" {
  type    = bool
  default = true
}

variable "create_ami_has_approved_tags_check_config_rule" {
  type    = bool
  default = true
}

variable "create_restrict_incoming_traffic_config_rule" {
  type    = bool
  default = true
}

variable "create_ec2_systems_manager_managed_check_config_rule" {
  type    = bool
  default = true
}

variable "create_ec2_instance_no_public_ip_config_rule" {
  type    = bool
  default = true
}

variable "create_lambda_function_public_access_prohibited_config_rule" {
  type    = bool
  default = true
}

variable "create_aurora_protected_by_backup_plan_config_rule" {
  type    = bool
  default = true
}

variable "create_aurora_backup_has_recovery_point_config_rule" {
  type    = bool
  default = true
}

variable "create_security_group_has_restricted_incoming_ssh_config_rule" {
  type    = bool
  default = true
}

variable "create_nacl_has_restricted_incoming_ssh_config_rule" {
  type    = bool
  default = true
}