#!/bin/bash
# file name: redshift-security.sh
# Finding: Redshift.1 Amazon Redshift clusters should prohibit public access
aws redshift describe-clusters | jq '.Clusters[].VpcSecurityGroups[].VpcSecurityGroupId' | while read sg_id; do
    aws ec2 revoke-security-group-ingress --group-id $sg_id --protocol tcp --port 0-65535 --cidr 0.0.0.0/0
done