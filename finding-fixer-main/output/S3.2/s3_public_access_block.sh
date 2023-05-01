#!/bin/bash
# s3_public_access_block.sh
# Finding: S3.2 S3 buckets should prohibit public read access

# Loop through all S3 buckets
for bucket in $(aws s3api list-buckets --query "Buckets[].Name" --output text)
do
  # Set bucket policy to block public read access
  aws s3api put-public-access-block --bucket $bucket --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
done