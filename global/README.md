# AWS Globals

This module is a collection of global resources that deploy IAM related resources as well as custom Config Rule and Remediation Lambdas.

### Directory layout
    .
    ├── global_iam              # Path containing global IAM roles, such as the AWSConfigRemediationRole.
    │   └── ...                 # Terraform configuration files.
    ├── data.tf                 # Data resource queries.
    ├── main.tf                 # Lambda and IAM module calls.
    ├── variables.tf            # Variables mostly consisting of Config Rule creation booleans.
    └── README.md               # Directory level README.md that this tree is built in.


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| role_name | The name of the AWS Config Assume Role IAM role. | string | AWSConfigRemediation | No |
| policy_name | The name of the AWS Config Assume Role IAM role policy. | string | AWSAutoRemediationPolicy | No |

## Outputs

This module does not currently export any outputs.