#!/bin/bash
# file name: remove_unused_credentials.sh
# Finding: IAM.8 Unused IAM user credentials should be removed

aws iam list-users --query "Users[*].UserName" --output text | while read user; do
    aws iam list-access-keys --user $user --query "AccessKeyMetadata[?CreateDate<'`date --date='90 days ago' --iso-8601`'].AccessKeyId" --output text | while read ak; do
        aws iam delete-access-key --access-key-id $ak --user $user
    done
done