#!/bin/bash
# filename: kms_key_rotation.sh
# Finding: KMS.4 AWS KMS key rotation should be enabled

aws kms list-keys | jq -r '.Keys[].KeyId' | while read keyId; do
  keyMetadata=$(aws kms describe-key --key-id $keyId)
  if [ $(echo $keyMetadata | jq -r '.KeyMetadata.EnableKeyRotation') == "false" ]; then
    aws kms enable-key-rotation --key-id $keyId
  fi
done