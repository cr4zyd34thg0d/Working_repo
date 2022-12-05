# AWS Config Rules and Remediations

Module for creating an AWS Config Rule and its Remediation.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| config_rule_name | The name of the AWS Config instance. | string | | Yes |
| config_rule_description | The description of the AWS Config instance. | string | | Yes|
| config_rule_type | CUSTOM_LAMBDA or AWS. | string | AWS | No|
| config_rule_source | SSM Document name or ARN of Custom Rule Lambda. | string | | Yes |
| config_rule_input_parameters | JSON string of Config Rule parameters. | string | null | No |
| config_role_name | Config execution role/assume IAM role name. | string | | Yes |
| config_logs_bucket | The name of the log bucket for use with config. | string | "" | No |
| create_remediation | Boolean to determine if the remediation resource needs to be created. | Boolean | false | No |
| remediation_resource_type | Resource types to be remediated. Follows a format like: AWS::ElasticLoadBalancing::LoadBalancer. | string | null | No|
| remediation_target_type | Resource type performing remediation. Usually SSM_DOCUMENT. | string | SSM_DOCUMENT | No |
| remediation_target_id | The name of the resource performing remediation. Usually the name of the SSM Document. | string | "" | No |
| remediation_parameters | List of objects representing parameter name and value. | list(object) | [] | No |

## Outputs

This module does not currently export any outputs.
