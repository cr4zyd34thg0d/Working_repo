#!/bin/bash
# s3-server-encrypt.sh
# Finding: S3.4 S3 buckets should have server-side encryption enabled
buckets=$(aws s3api list-buckets --query "Buckets[].Name" --output text)
for i in $buckets; do
    enc_status=$(aws s3api get-bucket-encryption --bucket $i --query "ServerSideEncryptionConfiguration.Rules[].ApplyServerSideEncryptionByDefault[].SSEAlgorithm" --output text)
    if [ -z "$enc_status" ]; then
        aws s3api put-bucket-encryption --bucket $i --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
    fi
done