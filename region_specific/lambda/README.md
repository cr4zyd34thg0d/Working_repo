# AWS Global Lambdas

This module is a collection of global resources that deploy custom Config Rule and Remediation Lambdas.

### Directory layout
    .
    ├── src                     # Path containing Lambda src code.
    │   ├── Remediations        # Python src for custom Config Rule Remediations
    │   └── Rules               # Python src for custom Config Rules
    ├── data.tf                 # Data resource queries.
    ├── iam.tf                  # Lambda assume roles.
    ├── kms.tf                  # KMS encryption keys
    ├── main.tf                 # Lambdas
    ├── outputs.tf              # Export Lambda ARNs
    └── README.md               # Directory level README.md that this tree is built in.


## Inputs

This module does not consume any inputs.

## Outputs

| Name | Description | 
|------|:-----------:|
| CW_Retention_Lambda_Arn | ARN for Lambda. |
| AMI_Public_Lambda_Arn | ARN for Lambda. |
| EBS_Public_Snapshot_Lambda_Arn | ARN for Lambda. |
| AMI_Public_Check_Lambda_Arn | ARN for Lambda. |
