#!/bin/bash
# filename: iam_users_policies.sh
# Finding: IAM.20 Avoid the use of the root user
aws iam get-account-authorization-details --query "UserDetailList[?contains(UserName,'root')].{User:UserName,Policies:UserPolicyList}"