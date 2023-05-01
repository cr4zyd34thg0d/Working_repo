#!/bin/bash
#terminate_ec2_instances.sh
# Finding: EC2.4 Stopped EC2 instances should be removed after a specified time period

aws ec2 describe-instances --filters "Name=instance-state-name,Values=stopped" | jq '.Reservations[].Instances[].InstanceId' | tr -d \" | while read INSTANCE_ID; do
aws ec2 describe-instances --instance-id $INSTANCE_ID | jq -r '.Reservations[].Instances[].LaunchTime' | while read LAUNCH_TIME; do
DURATION=$((($(date +%s)-$(date -d "$LAUNCH_TIME" +%s))/60))
if [ $DURATION -gt 60 ]; then
aws ec2 terminate-instances --instance-ids $INSTANCE_ID
fi
done
done