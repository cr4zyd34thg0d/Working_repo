#!/bin/bash
# filename: s3_bucket_review.sh
# Finding: S3.3 S3 buckets should prohibit public write access
aws s3api list-buckets --query "Buckets[].Name" --output text | while read bucket; do
    aws s3api get-bucket-acl --bucket "$bucket" | grep -q "Group\|AllUsers" && aws s3api put-bucket-acl --bucket "$bucket" --acl private
done