#!/bin/bash
# filename: sg_security_check.sh
# Finding: EC2.18 Security groups should only allow unrestricted incoming traffic for authorized ports

aws ec2 describe-security-groups --query 'SecurityGroups[*].[GroupId]' --output text | while read SG; do
    aws ec2 describe-security-groups --group-ids $SG --query 'SecurityGroups[*].[IpPermissions]' --output text | while read LINE; do
        if [[ $LINE =~ "0.0.0.0/0" ]]; then
            aws ec2 revoke-security-group-ingress --group-id $SG --protocol tcp --port 22 --cidr 0.0.0.0/0
            aws ec2 revoke-security-group-ingress --group-id $SG --protocol tcp --port 3389 --cidr 0.0.0.0/0
            aws ec2 revoke-security-group-ingress --group-id $SG --protocol tcp --port 5439 --cidr 0.0.0.0/0
            aws ec2 revoke-security-group-ingress --group-id $SG --protocol tcp --port 5432 --cidr 0.0.0.0/0
        fi
    done
done