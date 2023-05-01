#!/bin/bash
#remove_inbound_rules.sh
# Finding: EC2.21 Network ACLs should not allow ingress from 0.0.0.0/0 to port 22 or port 3389
aws ec2 describe-network-acls --query 'NetworkAcls[*].{ID:NetworkAclId,Associations:Associations[0].SubnetId}' --output text | while read line; do
    acl_id=$(echo $line | awk '{print $1}')
    echo "Removing inbound rule for $acl_id"
    aws ec2 delete-network-acl-entry --network-acl-id $acl_id --ingress --rule-number 100 --output text
done

aws ec2 describe-network-acls --query 'NetworkAcls[*].{ID:NetworkAclId,Associations:Associations[0].SubnetId}' --output text | while read line; do
    acl_id=$(echo $line | awk '{print $1}')
    echo "Removing inbound rule for $acl_id"
    aws ec2 delete-network-acl-entry --network-acl-id $acl_id --ingress --rule-number 110 --output text
done