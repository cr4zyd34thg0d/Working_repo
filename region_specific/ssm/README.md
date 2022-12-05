# AWS SSM Documents

Module for creating SSM Documents. Usually to either do a custom remediation via an SSM document or invoke an AWS Lambda to do the custom remediation.

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| region | Region of the deployment | string | true |
| account_id | Account deployment is in| string |---------| Yes |
| cw_retention_remediation_lambda_arn | Remediation Lambda ARN | string | Yes |
| ebs_public_snapshot_remediation_lambda_arn | Remediation Lambda ARN | string | Yes |
| ami_public_remediation_lambda_arn | Remediation Lambda ARN | string | Yes |
| aurora_pitr_remediation_lambda_arn | Remediation Lambda ARN| string | Yes |

## Outputs

| Name | Description | Type |
|------|-------------|:------:|
| cloudwatch_loggroup_retention_remediation_automation | Export all attributes | object |
| ssm_public_sharing_remediation | Export all attributes | object |
| ebs_snapshot_public_remediation| Export all attributes | object |
| ami_public_remediation| Export all attributes | object |
| aurora_pitr_remediation| Export all attributes | object |
