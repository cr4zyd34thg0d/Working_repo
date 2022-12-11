module "cloudtrail_enable" {
  source                 = "./modules/config_rule/EnableCloudTrail" #Update location for module
  config_name            = "cloudtrail_enable"                      #Update Config Rule Name
  config_role_arn        = ""
  config_role_name       = "Role_name"                #Update with Config role name
  config_aggregator_name = "config_aggregator"                  #Update Config Aggregator Name
  config_recorder_name   = "config_recorder"                    #Update with recorder name
  config_delivery_name   = "config_delivery"                    #Update with recorder name
  enable_config_recorder = true                                 #Update Boolean true/false
  config_logs_bucket     = "S3Bucket" #Update update for name of the bucket name for logging
  check_config           = true                                 #Update Boolean true/false
  rule_source            = "CLOUD_TRAIL_ENABLED"                #Update with the rule name to apply
}

module "cloudtrail_encryption" {
  source                 = "./modules/config_rule/CloudTrailEncryption" #Update location for module
  config_name            = "cloudtrail_encryption"                      #Update Config Rule Name
  config_role_arn        = ""
  config_role_name       = "Role_name"                #Update with Config role name
  config_aggregator_name = "config_aggregator"                  #Update Config Aggregator Name
  config_recorder_name   = "config_recorder"                    #Update with recorder name
  config_delivery_name   = "config_delivery"                    #Update with recorder name
  enable_config_recorder = true                                 #Update Boolean true/false
  config_logs_bucket     = "S3Bucket" #Update update for name of the bucket name for logging
  check_config           = true                                 #Update Boolean true/false
  rule_source            = "CLOUD_TRAIL_ENCRYPTION_ENABLED"     #Update with the rule name to apply
}
