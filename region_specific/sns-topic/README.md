# AWS SNS Topic and Notification

Module for creating an SNS Topic and its Notification Subscriptions. Usually to notify of a non-compliant AWS Config Rule in place of remediation.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tags | Tags to apply to resources. | map(string) | {} | No |
| sns_name | Name of the SNS Topic. | string | | Yes |
| account_id | Account deploying to. | string | | Yes|
| protocol| Protocol for SNS Topic. | string| "email" | No |
| email | Email to subscribe to topic. | string | | Yes |


## Outputs

| Name | Description | Type |
|------|-------------|:----:|
| arn | ARN of the SNS Topic | string|
