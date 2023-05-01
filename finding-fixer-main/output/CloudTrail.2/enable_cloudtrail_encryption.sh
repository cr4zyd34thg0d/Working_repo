#!/bin/bash
# enable_cloudtrail_encryption.sh
# Finding: CloudTrail.2 CloudTrail should have encryption at-rest enabled
aws cloudtrail describe-trails | jq '.trailList[].Name' | tr -d '"' | while read trail; do
  aws cloudtrail update-trail --name "$trail" --kms-id alias/aws/s3 --is-organization-trail | grep 'KmsKeyId\|IsOrganizationTrail'
done