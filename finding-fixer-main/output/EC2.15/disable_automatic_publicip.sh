#!/bin/bash
# disable-automatic-publicip.sh
# Finding: EC2.15 EC2 subnets should not automatically assign public IP addresses
aws ec2 describe-subnets --query 'Subnets[*].SubnetId' --output text | while read subnet_id 
do 
    aws ec2 modify-subnet-attribute --subnet-id $subnet_id --no-map-public-ip-on-launch 
done