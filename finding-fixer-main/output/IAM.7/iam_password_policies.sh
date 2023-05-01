#!/bin/bash
# iam_password_policies.sh
# Finding: IAM.7 Password policies for IAM users should have strong configurations
aws iam update-account-password-policy --minimum-password-length 12 --require-number --require-uppercase-character --require-lowercase-character --require-symbol-character --allow-users-to-change-password --max-password-age 90 --password-reuse-prevention 5