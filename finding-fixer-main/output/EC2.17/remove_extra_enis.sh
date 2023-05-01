#!/bin/bash

# Finding: EC2.17 EC2 instances should not use multiple ENIs
# File name: remove_extra_enis.sh

aws ec2 describe-instances --query "Reservations[].Instances[].[InstanceId,NetworkInterfaces[*].NetworkInterfaceId]" --output text | while read line; do
    instance_id=$(echo $line | awk '{print $1}')
    enis=$(echo $line | awk '{print $2}')
    if [ $(echo $enis | wc -w) -gt 1 ]; then
        for eni in $enis; do
            aws ec2 describe-network-interfaces --network-interface-ids $eni --query "NetworkInterfaces[*].Attachment.DeviceIndex" --output text | grep -q eth0
            if [ $? -eq 1 ]; then
                aws ec2 delete-network-interface --network-interface-id $eni
            fi
        done
    fi
done