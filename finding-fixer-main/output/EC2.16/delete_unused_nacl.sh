#!/bin/bash
# delete_unused_nacl.sh
# Finding: EC2.16 Unused Network Access Control Lists should be removed

for NACL_ID in $(aws ec2 describe-network-acls --query "NetworkAcls[?Associations == null][NetworkAclId]" --output text); do
  aws ec2 delete-network-acl --network-acl-id $NACL_ID
done