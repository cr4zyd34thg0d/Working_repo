#!/bin/bash
# set_autoscaling_metadata_response.sh
# Finding: AutoScaling.4 Auto Scaling group launch configuration should not have a metadata response hop limit greater than 1

IFS=$'\n'
for lc in $(aws autoscaling describe-launch-configurations --query "LaunchConfigurations[].LaunchConfigurationName" --output text); do
    aws autoscaling update-launch-configuration --launch-configuration-name $lc --metadata-options "{\"HttpTokens\":\"optional\",\"HttpPutResponseHopLimit\":1}"
done