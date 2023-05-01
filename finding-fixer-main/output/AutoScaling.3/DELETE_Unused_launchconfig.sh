#!/bin/bash

# Finding: AutoScaling.3 Auto Scaling group launch configurations should configure EC2 instances to require Instance Metadata Service Version 2 (IMDSv2)

# This script reviews all launch configurations in an AWS account and deletes ones that are not in use.

# Get a list of launch configurations
launch_configs=$(aws autoscaling describe-launch-configurations --query 'LaunchConfigurations[*].LaunchConfigurationName' --output text)

# Loop through each launch configuration
for launch_config in $launch_configs; do
  echo "Checking launch configuration $launch_config..."
  
  # Get a list of auto scaling groups that use the launch configuration
  auto_scaling_groups=$(aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[?LaunchConfigurationName==`'"$launch_config"'`].AutoScalingGroupName' --output text)
  
  if [ -z "$auto_scaling_groups" ]; then
    # Launch configuration is not being used, delete it
    echo "Launch configuration $launch_config is not being used, deleting it..."
    aws autoscaling delete-launch-configuration --launch-configuration-name "$launch_config"
  else
    # Launch configuration is being used, list the auto scaling groups that use it
    echo "Launch configuration $launch_config is being used by the following auto scaling groups:"
    echo "$auto_scaling_groups"
  fi
done
