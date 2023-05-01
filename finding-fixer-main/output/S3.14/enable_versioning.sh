#!/bin/bash

# Finding: S3.14

# This script inspects all S3 buckets in an account and enables versioning.

# Get list of S3 buckets
buckets=$(aws s3api list-buckets --query 'Buckets[*].Name' --output text)

# Loop through each bucket
for bucket in $buckets; do
  echo "Checking S3 bucket $bucket..."
  
  # Check if versioning is enabled
  versioning=$(aws s3api get-bucket-versioning --bucket "$bucket" --query 'Status' --output text)
  
  if [ "$versioning" != "Enabled" ]; then
    # Versioning is not enabled, enable it
    echo "Versioning is not enabled for S3 bucket $bucket, enabling it..."
    aws s3api put-bucket-versioning --bucket "$bucket" --versioning-configuration Status=Enabled
  else
    echo "Versioning is enabled for S3 bucket $bucket."
  fi
done