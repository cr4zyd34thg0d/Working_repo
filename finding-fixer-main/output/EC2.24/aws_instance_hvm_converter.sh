#!/bin/bash
# aws-instance-hvm-converter.sh
# Finding: EC2.24 EC2 paravirtual instance types should not be used

instance_ids=$(aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --output text)

for id in $instance_ids
do
    instance_type=$(aws ec2 describe-instances --instance-id $id --query 'Reservations[].Instances[].InstanceType' --output text)
    virtualization_type=$(aws ec2 describe-instances --instance-id $id --query 'Reservations[].Instances[].VirtualizationType' --output text)
    
    if [ $virtualization_type = "paravirtual" ]
    then
        new_instance_type=$(aws ec2 describe-instance-types --filters Name="virtualization-type",Values="hvm" --query 'InstanceTypes[0].InstanceType' --output text)
        aws ec2 modify-instance-attribute --instance-id $id --instance-type $new_instance_type
    fi
done