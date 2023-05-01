#!/bin/bash
# filename: cloudtrail_enable.sh
# Finding: CloudTrail.3 CloudTrail should be enabled

aws cloudtrail describe-trails --trail-name-list "Default" --region us-east-1 > /dev/null 2>&1

if [ $? -eq 0 ]; then 
  echo "CloudTrail is already enabled."
else
  aws cloudtrail create-trail --name "Default" --s3-bucket-name my-cloudtrail-bucket --region us-east-1
fi