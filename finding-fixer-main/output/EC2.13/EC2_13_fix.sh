#!/bin/bash
#sg_port_22_check.sh
# Finding: EC2.13 Security groups should not allow ingress from 0.0.0.0/0 to port 22

aws ec2 describe-security-groups | jq '.SecurityGroups[] | select(.IpPermissions[].ToPort == 22 and .IpPermissions[].IpRanges[].CidrIp == "0.0.0.0/0")'