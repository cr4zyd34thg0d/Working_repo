# AWS Global IAM

This module is a collection of global IAM resources.

### Directory layout
    .
    ├── main.tf                  # IAM creation
    ├── variables.tf            # Inputs
    └── README.md               # Directory level README.md that this tree is built in.


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| role_name | The name of the AWS Config Assume Role IAM role. | string | AWSConfigRemediation | No |
| policy_name | The name of the AWS Config Assume Role IAM role policy. | string | AWSAutoRemediationPolicy | No |

## Outputs

This module does not currently export and outputs.