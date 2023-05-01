#!/bin/bash

# Finding: EC2.8 EC2 instances should use Instance Metadata Service Version 2 (IMDSv2)

# This script enables IMDSv2 on a list of EC2 instances specified in a file.

# Set the instance ID file
instance_file="instance_ids.txt"
# Loop through each line in the file
while read -r instance; do
  # Check if instance is an ARN or an ID
  if [[ "$instance" == *"arn:aws:ec2"* ]]; then
    # Extract instance ID from instance ARN
    instance_id=${instance##*/}
  else
    # Use instance ID as-is
    instance_id="$instance"
  fi
  
  echo "Enabling IMDSv2 on instance $instance_id..."
  aws ec2 modify-instance-metadata-options --instance-id "$instance_id" --http-endpoint enabled --http-tokens required
done < "$instances_file"
