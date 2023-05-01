#!/bin/bash
# Filename: sqs_encryption.sh
# Finding: SQS.1 Amazon SQS queues should be encrypted at rest
aws sqs list-queues | jq -r '.QueueUrls[]' | while read url;
do
  is_encrypted=$(aws sqs get-queue-attributes --queue-url $url --attribute-names KmsMasterKeyId | jq -r '.Attributes.KmsMasterKeyId != null')
  if ! $is_encrypted; then
    aws sqs set-queue-attributes --queue-url $url --attributes KmsMasterKeyId=$(aws kms describe-key --key-id alias/aws/sqs --query 'KeyMetadata.KeyId' --output text)
  fi
done