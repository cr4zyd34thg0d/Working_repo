#!/bin/bash

# Finding: AutoScaling.3 Auto Scaling group launch configurations should configure EC2 instances to require Instance Metadata Service Version 2 (IMDSv2)


# This script reviews all launch templates in an AWS account and deletes ones that are not in use.

# Get a list of launch templates
launch_templates=$(aws ec2 describe-launch-templates --query 'LaunchTemplates[*].LaunchTemplateName' --output text)

# Loop through each launch template
for launch_template in $launch_templates; do
  echo "Checking launch template $launch_template..."
  
  # Get a list of auto scaling groups that use the launch template
  auto_scaling_groups=$(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?LaunchTemplate.LaunchTemplateName==\`$launch_template\`].AutoScalingGroupName" --output text)
  
  if [ -z "$auto_scaling_groups" ]; then
    # Launch template is not being used, delete it
    echo "Launch template $launch_template is not being used, deleting it..."
    aws ec2 delete-launch-template --launch-template-name "$launch_template"
  else
    # Launch template is being used, list the auto scaling groups that use it
    echo "Launch template $launch_template is being used by the following auto scaling groups:"
    echo "$auto_scaling_groups"
  fi
done