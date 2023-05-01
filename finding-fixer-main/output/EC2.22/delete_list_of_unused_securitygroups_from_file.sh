#!/bin/bash

# Finding: EC2.22 Unused EC2 security groups should be removed

# Read security group IDs from file
while read -r sg_id; do
  # Check if security group is in use
  in_use=$(aws ec2 describe-network-interfaces --filters Name=group-id,Values="$sg_id" --query 'NetworkInterfaces[*]' --output json)
  
  if [ -z "$in_use" ]; then
    # Delete security group if not in use
    echo "Deleting security group $sg_id..."
    aws ec2 delete-security-group --group-id "$sg_id"
  else
    echo "Security group $sg_id is in use and cannot be deleted."
  fi
done < sg_ids.txt
