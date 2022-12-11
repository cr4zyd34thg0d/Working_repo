# CloudWatch Template

template for setting up a Cloudwatch Alarm

## About This Module

This Module implements enables a cloudwatch alarm base dont eh metric filter set in the variables. It also creates a Log group or points to an already created log group. This module also creates and SNS topic connected to the alarm with a notification by Email.

## Brief Description on Setup

- A Cloudwatch alarm is created based on the metric filters set in the variables in main.tf.
- The log group is created or you can point to a log group in the variables.
- SNS topic is created with notification setup for Email. The Email can be adjusted via the variables in main.tf.

## How to Use This Module

- This module can be used in any AWS environment.
- The account used to deploy this module should have rights to assume the right account to allow for creating services/objects.
- Must have a way to deploy Terraform code.
- Change the variables in the main.tf:
```

module "cloudtrail_enable" {
  source                    = "./modules/config_rule/EnableCloudTrail" #Update location for module
  config_name               = "cloudtrail_enable"                      #Update Config Rule Name
  config_role_name          = "Role_name"                    #Update with Config role name
  config_aggregator_name    = "config_aggregator"                      #Update Config Aggregator Name
  config_recorder_name      = "config_recorder"                        #Update with recorder name
  config_delivery_name      = "config_delivery"                        #Update with recorder name
  enable_config_recorder    = true                                     #Update Boolean true/false
  config_logs_bucket        = "S3Bucket"     #Update update for name of the bucket name for logging
  check_config              = true                                     #Update Boolean true/false
  rule_source               = "CLOUD_TRAIL_ENABLED"                    #Update with the rule name to apply
}

```
- Run `terraform init` and `terraform apply`
Follow prompts to deploy the IaC (Infrstructure as Code) to your AWS environment.
