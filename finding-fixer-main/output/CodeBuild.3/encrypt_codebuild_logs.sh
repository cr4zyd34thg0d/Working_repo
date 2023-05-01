#!/bin/bash
# encrypt_codebuild_logs.sh
# Finding: CodeBuild.3 CodeBuild S3 logs should be encrypted

aws s3api put-bucket-encryption --bucket your-bucket-name --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}' --profile your-aws-cli-profile-name