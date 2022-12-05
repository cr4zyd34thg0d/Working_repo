resource "aws_cloudformation_stack" "gd_enabler" {
  name         = "guardduty-enabler" #Stack name
  capabilities = ["CAPABILITY_IAM"]
  parameters = {
    SecurityAccountId = "Audit/Security Account ID" #Aduit Account ID
    OrganizationId    = "ORG ID"                    #Adjust to ORg ID
    RegionFilter      = "test"                      #ControlTower or GuardDuty
    S3SourceBucket    = "test"                      #S3 Bucket with Zip
  }

  template_body = <<STACK
{
   "Parameters": {
      "SecurityAccountId": {
         "Type": "String",
         "Description": "Which account will be the GuardDuty Admin?  Enter the AWS account ID. (This is generally the AWS Control Tower Audit account)",
         "AllowedPattern": "^[0-9]{12}$",
         "ConstraintDescription": "The Security Account ID must be a 12 character string.",
         "MinLength": 12,
         "MaxLength": 12
      },
      "OrganizationId": {
         "Type": "String",
         "Description": "AWS Organizations ID for the Control Tower. This is used to restrict permissions to least privilege.",
         "MinLength": 12,
         "MaxLength": 12,
         "AllowedPattern": "^[o][\\-][a-z0-9]{10}$",
         "ConstraintDescription": "The Org Id must be a 12 character string starting with o- and followed by 10 lower case alphanumeric characters"
      },
      "RegionFilter": {
         "Type": "String",
         "Description": "Should GuardDuty be enabled for all GuardDuty supported regions, or only Control Tower supported regions?",
         "Default": "ControlTower",
         "AllowedValues": [
            "GuardDuty",
            "ControlTower"
         ]
      },
      "S3SourceBucket": {
         "Type": "String",
         "Description": "Which S3 bucket contains the guardduty_enabler.zip file for the GuardDutyEnabler lambda function?"
      },
      "S3SourceFile": {
         "Type": "String",
         "Description": "What is the S3 path to the zip file for the GuardDutyEnabler lambda function?",
         "Default": "guardduty_enabler.zip"
      },
      "ComplianceFrequency": {
         "Type": "Number",
         "Description": "How frequently (in minutes, between 1 and 3600, default is 60) should organizational compliance be checked?",
         "Default": 60,
         "MinValue": 1,
         "MaxValue": 3600,
         "ConstraintDescription": "Compliance Frequency must be a number between 1 and 3600, inclusive."
      },
      "RoleToAssume": {
         "Type": "String",
         "Default": "AWSControlTowerExecution",
         "Description": "What role should be assumed in child accounts to enable GuardDuty?  The default is AWSControlTowerExecution for a Control Tower Environment."
      }
   },
   "Resources": {
      "GuardDutyEnablerRole": {
         "Type": "AWS::IAM::Role",
         "Properties": {
            "AssumeRolePolicyDocument": {
               "Version": "2012-10-17",
               "Statement": [
                  {
                     "Effect": "Allow",
                     "Principal": {
                        "Service": [
                           "lambda.amazonaws.com"
                        ]
                     },
                     "Action": "sts:AssumeRole"
                  }
               ]
            },
            "Policies": [
               {
                  "PolicyName": "GuardDutyEnablerPolicy",
                  "PolicyDocument": {
                     "Version": "2012-10-17",
                     "Statement": [
                        {
                           "Effect": "Allow",
                           "Action": [
                              "organizations:ListAccounts",
                              "organizations:DescribeAccount"
                           ],
                           "Resource": "*",
                           "Condition": {
                              "StringEquals": {
                                 "aws:PrincipalOrgId": { "Fn::Sub" : "$${OrganizationId}"}
                              }
                           }
                        },
                        {
                           "Effect": "Allow",
                           "Action": "sts:AssumeRole",
                           "Resource": { "Fn::Sub" : "arn:$${AWS::Partition}:iam::*:role/$${RoleToAssume}"},
                           "Condition": {
                              "StringEquals": {
                                 "aws:PrincipalOrgId": { "Fn::Sub" : "$${OrganizationId}"}
                              }
                           }
                        },
                        {
                           "Effect": "Allow",
                           "Action": "sns:Publish",
                           "Resource": { "Ref" : "GuardDutyEnablerTopic"}
                        },
                        {
                           "Effect": "Allow",
                           "Action": [
                              "logs:CreateLogGroup",
                              "logs:CreateLogStream",
                              "logs:PutLogEvents"
                           ],
                           "Resource": [
                              { "Fn::Sub" : "arn:$${AWS::Partition}:logs:$${AWS::Region}:$${AWS::AccountId}:log-group:/aws/lambda/*"}
                           ]
                        },
                        {
                           "Effect": "Allow",
                           "Action": "CloudFormation:ListStackInstances",
                           "Resource": { "Fn::Sub" : "arn:$${AWS::Partition}:cloudformation:$${AWS::Region}:$${AWS::AccountId}:stackset/AWSControlTowerBP-BASELINE-CLOUDWATCH:*"}
                        },
                        {
                           "Effect": "Allow",
                           "Action": [
                              "iam:GetRole",
                              "iam:CreateServiceLinkedRole"
                           ],
                           "Resource": "*"
                        },
                        {
                           "Effect": "Allow",
                           "Action": "sts:AssumeRole",
                           "Resource": { "Fn::Sub" : "arn:$${AWS::Partition}:iam::*:role/$${RoleToAssume}"}
                        },
                        {
                           "Effect": "Allow",
                           "Action": [
                              "guardduty:acceptinvitation",
                              "guardduty:createdetector",
                              "guardduty:createmembers",
                              "guardduty:getdetector",
                              "guardduty:invitemembers",
                              "guardduty:listdetectors",
                              "guardduty:listmembers",
                              "guardduty:listinvitations",
                              "guardduty:updatedetector"
                           ],
                           "Resource": "*"
                        }
                     ]
                  }
               }
            ]
         },
         "Metadata": {
            "cfn_nag": {
               "rules_to_suppress": [
                  {
                     "id": "W11",
                     "reason": "Organizations doesn't have arns, so we have to use an asterisk in the policy"
                  }
               ]
            }
         }
      },
      "GuardDutyEnablerLambda": {
         "DependsOn": "GuardDutyEnablerRole",
         "Type": "AWS::Lambda::Function",
         "Properties": {
            "Handler": "guardduty_enabler.lambda_handler",
            "Role": { "Fn::Sub" : "arn:$${AWS::Partition}:iam::$${AWS::AccountId}:role/$${GuardDutyEnablerRole}"},
            "Code": {
               "S3Bucket": { "Ref" : "S3SourceBucket"},
               "S3Key": { "Ref" : "S3SourceFile"}
            },
            "Runtime": "python3.7",
            "MemorySize": 128,
            "Timeout": 300,
            "Environment": {
               "Variables": {
                  "assume_role": { "Fn::Sub" : "$${RoleToAssume}"},
                  "region_filter": { "Ref" : "RegionFilter"},
                  "ct_root_account": { "Fn::Sub" : "$${AWS::AccountId}"},
                  "admin_account": { "Fn::Sub" : "$${SecurityAccountId}"},
                  "topic": {"Ref" : "GuardDutyEnablerTopic"},
                  "log_level": "ERROR"
               }
            }
         }
      },
      "GuardDutyEnablerTopic": {
         "Type": "AWS::SNS::Topic",
         "Properties": {
            "DisplayName": "GuardDuty_Enabler",
            "TopicName": "GuardDutyEnablerTopic"
         }
      },
      "GuardDutyEnablerTopicLambdaPermission": {
         "Type": "AWS::Lambda::Permission",
         "Properties": {
            "Action": "lambda:InvokeFunction",
            "FunctionName": { "Fn::GetAtt" : "GuardDutyEnablerLambda.Arn"},
            "Principal": "sns.amazonaws.com",
            "SourceArn": { "Ref" : "GuardDutyEnablerTopic"}
         }
      },
      "GuardDutyEnablerSubscription": {
         "Type": "AWS::SNS::Subscription",
         "Properties": {
            "Endpoint": { "Fn::GetAtt" : "GuardDutyEnablerLambda.Arn"},
            "Protocol": "lambda",
            "TopicArn": { "Ref" : "GuardDutyEnablerTopic"}
         }
      },
      "GDScheduledRule": {
         "Type": "AWS::Events::Rule",
         "Properties": {
            "Description": "GuardDutyScheduledComplianceTrigger",
            "ScheduleExpression": { "Fn::Sub" : "rate($${ComplianceFrequency} minutes)"},
            "State": "ENABLED",
            "Targets": [
               {
                  "Arn": {"Fn::GetAtt" : "GuardDutyEnablerLambda.Arn"},
                  "Id": "DailyInvite"
               }
            ]
         }
      },
      "GDLifeCycleRule": {
         "Type": "AWS::Events::Rule",
         "Properties": {
            "Description": "GuardDutyLifeCycleTrigger",
            "EventPattern": {
               "source": [
                  "aws.controltower"
               ],
               "detail-type": [
                  "AWS Service Event via CloudTrail"
               ],
               "detail": {
                  "eventName": [
                     "CreateManagedAccount"
                  ]
               }
            },
            "State": "ENABLED",
            "Targets": [
               {
                  "Arn": {"Fn::GetAtt" : "GuardDutyEnablerLambda.Arn"},
                  "Id": "DailyInvite"
               }
            ]
         }
      },
      "GuardDutyEnablerPermissionForEventsToInvokeLambda": {
         "Type": "AWS::Lambda::Permission",
         "Properties": {
            "FunctionName": { "Fn::GetAtt" : "GuardDutyEnablerLambda.Arn"},
            "Action": "lambda:InvokeFunction",
            "Principal": "events.amazonaws.com",
            "SourceArn": { "Fn::GetAtt" : "GDScheduledRule.Arn"}
         }
      },
      "GuardDutyEnablerPermissionForLifecycleEventsToInvokeLambda": {
         "Type": "AWS::Lambda::Permission",
         "Properties": {
            "FunctionName": { "Fn::GetAtt" : "GuardDutyEnablerLambda.Arn"},
            "Action": "lambda:InvokeFunction",
            "Principal": "events.amazonaws.com",
            "SourceArn": { "Fn::GetAtt" : "GDLifeCycleRule.Arn"}
         }
      },
      "GuardDutyEnablerLambdaFirstRun": {
         "DependsOn": [
            "GuardDutyEnablerTopic",
            "GuardDutyEnablerRole",
            "GuardDutyEnablerTopicLambdaPermission",
            "GuardDutyEnablerSubscription"
         ],
         "Type": "Custom::GuardDutyEnablerLambdaFirstRun",
         "Properties": {
            "ServiceToken": { "Fn::GetAtt" : "GuardDutyEnablerLambda.Arn"}
         }
      }
   }
}
STACK
}
