#!/bin/bash
#filename: ebs_vol_encryption.sh
# Finding: EC2.3 Attached EBS volumes should be encrypted at-rest

#List all EBS volumes in the account
volumes=$(aws ec2 describe-volumes --query 'Volumes[*].VolumeId' --output text)

#Loop through the volumes
for volume in $volumes
do
  #Check if encryption is already enabled
  encrypted=$(aws ec2 describe-volumes --volume-ids $volume --query 'Volumes[*].Encrypted' --output text)
  
  if [ "$encrypted" = "False" ]; then
    #Enable encryption
    aws ec2 modify-volume --volume-id $volume --encrypted
  fi
done