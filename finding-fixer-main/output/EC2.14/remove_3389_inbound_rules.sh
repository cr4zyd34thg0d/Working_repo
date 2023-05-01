#!/bin/bash
# remove-3389-inbound-rules.sh
# Finding: EC2.14 Ensure no security groups allow ingress from 0.0.0.0/0 to port 3389
aws ec2 describe-security-groups --query "SecurityGroups[].[GroupId]" --output text | while read SGID; do
    aws ec2 revoke-security-group-ingress --group-id $SGID --protocol tcp --port 3389 --cidr 0.0.0.0/0
done