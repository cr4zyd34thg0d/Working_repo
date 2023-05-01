#!/bin/bash
# filename: ebs_encryption_check.sh
# Finding: EC2.7 EBS default encryption should be enabled

aws ec2 describe-volumes --filters Name=encrypted,Values=false | jq '.Volumes[] | select(.State=="in-use") | select(.Attachments[0].DeleteOnTermination==false) | .Attachments[0].InstanceId, .Attachments[0].VolumeId' | awk '{ORS=" "; print} NR%2==0 {ORS="\n"}' | while read -r instance volume; do
    aws ec2 modify-volume --volume-id "$volume" --encrypted
done