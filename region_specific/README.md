# AWS Config Rules, Remediation, and Related Resources

This module is a collection of regional resources that are used to deploy AWS Config Rules & Remediations, SSM Documents, and an SNS Topic with notification subscriptions.

### Directory layout
    .
    ├── config                  # Path containing Config Rule and Remediation configurations.
    │   └── ...                 # Terraform configuration files.
    ├── sns-topic               # Path containing SNS Topic configuration files.
    │   └── ...                 # Terraform configuration files for deploying SNS Topic.
    ├── ssm                     # Path containing SSM Document configuration files and SSM Document template files.
    │   ├── ssm_docs            # Directory for SSM Document template files.
    │   └── ...                 # Terraform configuration files for deploying SSM Documents using files in ssm_docs.
    ├── data.tf                 # Data resource queries.
    ├── main.tf                 # Config, SNS, SSM module calls.
    ├── variables.tf            # Variables mostly consisting of Config Rule creation booleans.
    └── README.md               # Directory level README.md that this tree is built in.

## To Add/Modify/Delete SSM Documents

There may be times that you need to create a custom SSM document to either perform some remediation or to invoke a Lambda to do more complex remediations. SSM documents will always be the "endpoint" for a Config Rule's Remediation; however, rather you the remediation can be done straight from the SSM document or if the SSM document needs to invoke a Lambda for the remediation is totally dependent on the use-case and complexity as well as the outputs of the Config Rule. Sometimes AWS Managed Config Rules will not output the ID of the NON_COMPLIANT resource but rather just the AWS account ID the NON_COMPLIANT resource lives in.

### Simple SSM Document remediation
For example, if your remediation is very simple and can be done with a single API call you can do the remediation from the SSM document itself. See below:

```JSON
{
    "description": "Automation Document Example JSON Template",
    "schemaVersion": "0.3",
    "assumeRole": "{{ AutomationAssumeRole }}",
    "parameters": {
        "AutomationAssumeRole": {
            "type": "String",
            "description": "The ARN of the role"
        },
        "SSMDocumentID": {
            "type": "String",
            "description": "{{ SSMDocumentID }} is populated by RESOURCE_ID from the Config Rule"
        }
    },
    "mainSteps": [
        {
            "name": "SSMRemediation",
            "action": "aws:executeAwsApi",
            "inputs": {
                "Service": "ssm",
                "Api": "modify-document-permission",
                "Name": "{{SSMDocumentID}}",
                "PermissionType": "Share",
                "AccountIdsToRemove": ["All"]
            }
        }
    ]
}
```

In the above snippet, the parameter `{{SSMDocumentID}}` is passed into the the mainSteps field where you can see we are performing an `aws:executeAwsAPI` action on the ssm:ModifyDocumentPermission API call. `Name`,`PermissionType`, and `AccountIdsToRemove` are all parameters for that API call. See the [AWS CLI Documentation](https://docs.aws.amazon.com/cli/latest/reference/ssm/modify-document-permission.html) for more information.

Because we directly have the resource ID and only need to make a single API call, we can do this remediation from the SSM Document itself.

### More complex SSM Document remediation

For a more complex example, we must use the SSM document to invoke a Lambda to do the remediation. See below:

```JSON 
{
  "description": "Automation Document Example JSON Template",  
  "schemaVersion": "0.3",  
  "assumeRole": "{{ AutomationAssumeRole }}",  
  "parameters": {  
    "AutomationAssumeRole": {  
      "type": "String",  
      "description": "The ARN of the role",  
      "default": ""  
    }
  },  
  "mainSteps": [  
    {  
      "name": "invokeMyLambdaFunction",  
      "action": "aws:invokeLambdaFunction",  
      "maxAttempts": 3,  
      "timeoutSeconds": 120,  
      "onFailure": "Abort",  
      "inputs": {  
        "FunctionName": "${EBSPublicSnapshotRemediationLambda}",  
        "Payload": "{\"parameterName\":\"AccountID\"}"  
      }  
    }
  ]  
}
```

As you see above, there is no resource ID parameter like the previous example. This is because the Config Rule that uses this SSM document as a remediation does not provide that as an output. Thus, we must invoke the Lambda in the SSM document and then query for details that we need in the Lambda. See below:

```Python
try:
    snapshots = []
    response = client.describe_snapshots(
        MaxResults=1000,
        RestorableByUserIds=[
            'all',
        ],
        OwnerIds=[
            'self',
        ]
    )
    snapshots = response['Snapshots']

    while 'NextToken' in response.keys():
        response = client.describe_snapshots(
            MaxResults=1000,
            NextToken=response['NextToken'],
            RestorableByUserIds=[
                'all',
            ],
            OwnerIds=[
                'self',
            ]
        )
        snapshots.append(response['Snapshots'])

    logging.info(str(snapshots))

    for snapshot in snapshots:
        response = client.modify_snapshot_attribute(
            Attribute='createVolumePermission',
            CreateVolumePermission={
                'Remove': [
                    {
                        'Group': 'all',
                    },
                ]
            },
            SnapshotId=snapshot['SnapshotId'],
        )
    
    logging.info(str(response))
except Exception as e:
    logging.error(str(e))
    return {
        'statusCode': 500,
        'body': json.dumps(str(e))
    }
```

Here, you can see we are describing all snapshots in our AWS account that are both Public and Owned by us. Once that list is gathered, we begin remediating them by removing public access.

For more references on SSM documents, see the (official AWS documentation on SSM documents)[https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-ssm-docs.html].

## To Add/Modify/Delete SNS Topics and Notifications

There may be cases where automatic remediation may just be too complex, too risky, or have too many variables to keep track of. In those cases, you may want human intervention and some form of notification that something is NON_COMPLIANT that needs attention.

For that, we can use SNS Topics and subscriptions to get notified.

```hcl
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
```

First, we need to create our CW Event Rule to capture what we are looking for. In this case, we are looking for events from the `aws.config` service source, from the `configRuleName` of Restrict_Incoming_Traffic_Check and specifically when it becomes NON_COMPLIANT. Great! But how do we get notified? Well, in this repository exist an SNS Topic creation so we must simple subscribe to it like below:

```hcl
resource "aws_cloudwatch_event_target" "restrict_incoming_traffic_config_rule_notification-to_sns_notification" {
  count = var.create_restrict_incoming_traffic_config_rule ? 1 : 0

  rule      = aws_cloudwatch_event_rule.restrict_incoming_traffic_config_rule_notification[0].name
  target_id = "SendToSNS"
  arn       = module.sns_topic.arn

  input_transformer {
    input_paths = {
      awsRegion : "$.detail.awsRegion",
      resourceId : "$.detail.resourceId",
      awsAccountId : "$.detail.awsAccountId",
      compliance : "$.detail.newEvaluationResult.complianceType",
      rule : "$.detail.configRuleName",
      time : "$.detail.newEvaluationResult.resultRecordedTime",
      resourceType : "$.detail.resourceType"
    }
    input_template = "\"On <time> AWS Config rule <rule> evaluated the <resourceType> with Id <resourceId> in the account <awsAccountId> region <awsRegion> as <compliance> For more details open the AWS Config console at https://console.aws.amazon.com/config/home?region=<awsRegion>#/timeline/<resourceType>/<resourceId>/configuration\""
  }
}
```

As you can see, we take our rule from above and set the SNS topic as the target. The `input_transformer` simplt takes details from the event and allows you to craft your own message as we did in the `input_template` field.

For more references, see the below link:

[How can I be notified when an AWS resource is non-compliant using AWS Config?](https://aws.amazon.com/premiumsupport/knowledge-center/config-resource-non-compliant/)


## To Add/Modify/Delete new Config rules

Now that I showed how to create custom SSM documents for custom remediations (either in the document itself or invoking a Lambda from the document) and how to get notified when a Config Rule becomes NON_COMPLIANT I will now talk about Config Rules themselves.

First, there are custom Config Rules using AWS Lambda and AWS Managed Config Rules. Of course, using Lambda for custom Config Rules is a last resort if there are no AWS managed rules for your use-case. Secondly, there is the AWS Managed Config Rules.

### Custom Lambda Config Rules
First, I will talk about a custom Lambda Config Rule:

```hcl
module "ami_public_check_config_rule" {
  count = var.create_ami_public_check_config_rule ? 1 : 0

  source                  = "./config"
  config_rule_name        = "AMI_Public_Image_Check"
  config_rule_source      = local.ami_public_lambda_arn
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
```

Re-using the module at `./config` allows us to re-use our code. See the `README.md` under that path for more details on the fields above. As you can see, for our `config_rule_source` we are reference a Lambda ARN. This is a Lambda that was custom built and deployed in the account this Config Rule is deployed in and utilized by it. You can see we need to let the resource know we are using a `CUSTOM_LAMBDA` in the `config_rule_type` field. We are also using a custom remediation that takes the type of `SSM_DOCUMENT` and lives at the path of `module.ssm_documents.ami_public_remediation`. We also pass in the `remediation_parameters` that are specific to our remediation `SSM_DOCUMENT`.

The Lambda code is far too large to take a snippet of, but it can be found at: `../global/global_lambdas/src/Rules/AMIPublicCheckRuleLambda/lambda_function.py`

### AWS Managed Config Rules

Very similar to the above, creating a Config Rule with AWS Managed Rules is even easier. You simply find the [identifier](https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html) of the rule you need and plug it in like so:

```hcl
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
```

Notice in this example, both the Remediation and the Config Rule are AWS Managed.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_s3_block_public_access_bucket_level_check_config_rule | Enable/Disable AWS Config Rule: "S3_BUCKET_LEVEL_PUBLIC_ACCESS_PROHIBITED" | Boolean | true | No |
| create_s3_block_public_access_account_level_check_config_rule | Enable/Disable AWS Config Rule: "S3_ACCOUNT_LEVEL_PUBLIC_ACCESS_BLOCKS" | Boolean | true | No |
| create_elb_log_enabled_check_config_rule | Enable/Disable AWS Config Rule: "ELB_LOGGING_ENABLED" | Boolean | true | No |
| create_vpc_sg_open_only_to_authorized_ports_check_config_rule | Enable/Disable AWS Config Rule: "VPC_SG_OPEN_ONLY_TO_AUTHORIZED_PORTS"| Boolean | true | No |
| create_cw_loggroup_retention_period_check_config_rule | Enable/Disable AWS Config Rule: "CW_LOGGROUP_RETENTION_PERIOD_CHECK" | Boolean | true | No |
| create_ebs_snapshot_public_restorable_check_config_rule | Enable/Disable AWS Config Rule: "EBS_SNAPSHOT_PUBLIC_RESTORABLE_CHECK" | Boolean | true | No |
| create_secret_key_rotation_check_config_rule | Enable/Disable AWS Config Rule: "SECRETSMANAGER_ROTATION_ENABLED_CHECK" | Boolean | true | No |
| create_ec2_without_profile_check_config_rule | Enable/Disable AWS Config Rule: "EC2_INSTANCE_PROFILE_ATTACHED" | Boolean | true | No |
| create_ec2_ebs_encryption_by_default_check_config_rule | Enable/Disable AWS Config Rule: "EC2_EBS_ENCRYPTION_BY_DEFAULT" | Boolean | true | No |
| create_secret_key_rotation_success_check_config_rule | Enable/Disable AWS Config Rule: "SECRETSMANAGER_SCHEDULED_ROTATION_SUCCESS_CHECK" | Boolean | true | No |
| create_ssm_document_public_check_config_rule | Enable/Disable AWS Config Rule: "SSM_DOCUMENT_NOT_PUBLIC" | Boolean | true | No |
| create_cloudtrail_security_trail_enabled_check_config_rule | Enable/Disable AWS Config Rule: "CLOUDTRAIL_SECURITY_TRAIL_ENABLED" | Boolean | true | No |
| create_ami_public_check_config_rule | Enable/Disable AWS Config Rule: "CUSTOM_RULE_LAMBDA"| Boolean | true | No |
| create_acm_certificate_expiration_check_config_rule | Enable/Disable AWS Config Rule: "ACM_CERTIFICATE_EXPIRATION_CHECK" | Boolean | true | No |
| create_iam_root_user_access_key_check_config_rule | Enable/Disable AWS Config Rule: "IAM_ROOT_ACCESS_KEY_CHECK" | Boolean | true | No |
| create_ami_has_approved_tags_check_config_rule | Enable/Disable AWS Config Rule: "APPROVED_AMIS_BY_TAG" | Boolean | true | No |
| create_restrict_incoming_traffic_config_rule | Enable/Disable AWS Config Rule: "RESTRICTED_INCOMING_TRAFFIC" | Boolean | true | No |
| create_ec2_systems_manager_managed_check_config_rule | Enable/Disable AWS Config Rule: "EC2_INSTANCE_MANAGED_BY_SSM" | Boolean | HARD DISABLED | No |
| create_ec2_instance_no_public_ip_config_rule | Enable/Disable AWS Config Rule: "EC2_INSTANCE_NO_PUBLIC_IP" | Boolean | true | No |
| create_lambda_function_public_access_prohibited_config_rule | Enable/Disable AWS Config Rule: "LAMBDA_FUNCTION_PUBLIC_ACCESS_PROHIBITED"| Boolean | true | No |
| create_aurora_protected_by_backup_plan_config_rule | Enable/Disable AWS Config Rule: "AURORA_RESOURCES_PROTECTED_BY_BACKUP_PLAN" | Boolean | true | No |
| create_aurora_backup_has_recovery_point_config_rule | Enable/Disable AWS Config Rule: "AURORA_LAST_BACKUP_RECOVERY_POINT_CREATED" | Boolean | true | No |
| create_security_group_has_restricted_incoming_ssh_config_rule | Enable/Disable AWS Config Rule: "INCOMING_SSH_DISABLED | Boolean | true | No |
| create_nacl_has_restricted_incoming_ssh_config_rule | Enable/Disable AWS Config Rule: "NACL_NO_UNRESTRICTED_SSH_RDP" | Boolean | HARD DISABLED | No |

## Outputs

This module does not currently export any outputs.