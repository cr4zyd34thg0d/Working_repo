#!/bin/bash

# Finding: AutoScaling.3 Auto Scaling group launch configurations should configure EC2 instances to require Instance Metadata Service Version 2 (IMDSv2)

# This script ensures that every Auto Scaling group launch configuration specifies EC2 instances to require IMDSv2.

# Get list of Auto Scaling group names
asg_names=$(aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[*].AutoScalingGroupName' --output text)

# Loop through each Auto Scaling group
for asg_name in $asg_names; do
  echo "Checking launch configuration for Auto Scaling group $asg_name..."
  
  # Get launch configuration name
  lc_name=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$asg_name" --query 'AutoScalingGroups[*].LaunchConfigurationName' --output text)
  
  # Check if launch configuration requires IMDSv2
  lc_metadata=$(aws autoscaling describe-launch-configurations --launch-configuration-names "$lc_name" --query 'LaunchConfigurations[*].MetadataOptions' --output json)
  lc_imdsv2=$(echo "$lc_metadata" | jq -r '.[] | select(.HttpTokens == "required" and .HttpEndpoint == "enabled")')
  
  if [ -z "$lc_imdsv2" ]; then
    # Launch configuration does not require IMDSv2, update it
    echo "Updating launch configuration $lc_name to require IMDSv2..."
    aws autoscaling update-launch-configuration --launch-configuration-name "$lc_name" --metadata-options HttpEndpoint=enabled,HttpTokens=required
  else
    echo "Launch configuration $lc_name already requires IMDSv2."
  fi
done
