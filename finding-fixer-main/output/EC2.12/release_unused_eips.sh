#!/bin/bash
# release_unused_eips.sh
# Finding: EC2.12 Unused EC2 EIPs should be removed

aws ec2 describe-instances | jq -r '.Reservations[].Instances[].InstanceId' | while read instance_id; do
  aws ec2 describe-addresses --filters "Name=instance-id,Values=$instance_id" | jq -r '.Addresses[].AllocationId' | while read allocation_id; do
    aws ec2 release-address --allocation-id $allocation_id
  done
done