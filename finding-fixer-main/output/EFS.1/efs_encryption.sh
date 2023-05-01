#!/bin/bash
# Filename: efs-encryption.sh
# Finding: EFS.1 Elastic File System should be configured to encrypt file data at-rest using AWS KMS

# Review Elastic File System configurations and enable encryption if not already enabled.
aws efs describe-file-systems | grep -q "KmsKeyId"
if [ $? -eq 0 ]; then
  echo "Encryption is already enabled."
else
  echo "Enabling encryption..."
  KEY_ID=YOUR_KMS_KEY_ID
  aws efs put-file-system-encryption-config --file-system-id YOUR_FILE_SYSTEM_ID --encrypted true --kms-key-id $KEY_ID
fi