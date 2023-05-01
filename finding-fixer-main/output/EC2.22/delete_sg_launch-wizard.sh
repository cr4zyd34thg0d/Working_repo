#!/bin/bash

# Finding: EC2.22 Unused EC2 security groups should be removed

# This script finds and deletes unused security groups whos names starts with "launch-wizard" in every VPC in a region,
# and lists what uses them if they are being used.



# Get a list of VPC IDs in the region
vpc_ids=$(aws ec2 describe-vpcs --query 'Vpcs[*].VpcId' --output text)

# Loop through each VPC
for vpc_id in $vpc_ids; do
  echo "Checking VPC $vpc_id..."
  
  # Get a list of security groups in the VPC that match the prefix "launch-wizard"
  security_groups=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpc_id" "Name=group-name,Values=launch-wizard*" --query 'SecurityGroups[*].GroupId' --output text)
  
  # Loop through each security group
  for sg in $security_groups; do
    echo "Checking security group $sg..."
    
    # Get a list of instances that use the security group
    instances=$(aws ec2 describe-instances --filters "Name=vpc-id,Values=$vpc_id" "Name=instance.group-id,Values=$sg" --query 'Reservations[*].Instances[*].InstanceId' --output text )
    
    if [ -z "$instances" ]; then
      # Security group is not being used, delete it
      echo "Security group $sg is not being used, deleting it..."
      aws ec2 delete-security-group --group-id "$sg"
    else
      # Security group is being used, list the instances that use it
      echo "Security group $sg is being used by the following instances:"
      echo "$instances"
    fi
  done
done
