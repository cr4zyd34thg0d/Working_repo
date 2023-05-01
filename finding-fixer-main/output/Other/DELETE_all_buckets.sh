#!/bin/bash

# This script sets the S3 lifecycle policy for each bucket in the account to delete everything, including object versions and partial uploads, after 1 day.
# WARNING:  This DELETES ALL FILES after 24h

# Get a list of S3 buckets in the account
buckets=$(aws s3api list-buckets --query 'Buckets[*].Name' --output text)

# Loop through each bucket
for bucket in $buckets; do
  echo "Setting S3 lifecycle policy for bucket $bucket..."
  
  # Set the S3 lifecycle policy for the bucket to delete everything after 1 day, including object versions and partial uploads
  aws s3api put-bucket-lifecycle-configuration --bucket "$bucket" --lifecycle-configuration '{"Rules":[{"Status":"Enabled","Prefix":"","ID":"Delete objects after 1 day","Expiration":{"Days":1},"NoncurrentVersionExpiration":{"NoncurrentDays":1},"AbortIncompleteMultipartUpload":{"DaysAfterInitiation":1}}]}'
done
