#!/bin/bash
#Filename: s3_block_public_access.sh
# Finding: S3.1 S3 Block Public Access setting should be enabled

# Loop through all S3 buckets
for bucket in $(aws s3api list-buckets --query "Buckets[].Name" --output text)
do
  # Set bucket policy to block public read access
  aws s3api put-public-access-block --bucket $bucket --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
done