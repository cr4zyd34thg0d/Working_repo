#!/bin/bash
# no_public_ips.sh
# Finding: Autoscaling.5 Amazon EC2 instances launched using Auto Scaling group launch configurations should not have Public IP addresses
aws autoscaling describe-launch-configurations --query "LaunchConfigurations[?contains(IamInstanceProfile, 'no_public_ips')].LaunchConfigurationName" --output text | xargs -I {} aws autoscaling describe-launch-configurations --launch-configuration-names {} --query "LaunchConfigurations[0].InstanceId" --output text | xargs -I {} aws ec2 modify-instance-attribute --instance-id {} --no-source-dest-check