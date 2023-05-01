#!/bin/bash

# Finding: EC2.19 Security groups should not allow unrestricted access to ports with high risk

# This script finds security groups that have a "high risk" port open to 0.0.0.0/0
# and changes the range to the IP range of the VPC they are in.

# Get list of security group IDs from file
sg_ids_file="sg_ids.txt"
sg_ids=$(cat "$sg_ids_file")

# List of high-risk ports to check
high_risk_ports=(3389 20 21 22 23 110 143 3306 8080 1433 1434 9200 9300 5601 25 445 135 4333 5432 5500)

# Loop through each security group
for sg_id in $sg_ids; do
  echo "Checking security group $sg_id..."
  
  # Get VPC CIDR
  vpc_cidr=$(aws ec2 describe-security-groups --group-id "$sg_id" --query 'SecurityGroups[*].VpcId' --output text | xargs -I {} aws ec2 describe-vpcs --vpc-ids {} --query 'Vpcs[*].CidrBlock' --output text)
  
  # Find inbound rules with high-risk ports open to 0.0.0.0/0
  for port in "${high_risk_ports[@]}"; do
    rule=$(aws ec2 describe-security-groups --group-id "$sg_id" --query "SecurityGroups[*].IpPermissions[?ToPort==\`${port}\` && CidrIp==\`0.0.0.0/0\`] | [0]" --output json)
    
    if [ -z "$rule" ]; then
      # Rule not found, skip to next port
      continue
    fi
    
    # Update inbound rule to use VPC CIDR range
    aws ec2 revoke-security-group-ingress --group-id "$sg_id" --ip-permissions "$rule"
    aws ec2 authorize-security-group-ingress --group-id "$sg_id" --protocol tcp --port "$port" --cidr "$vpc_cidr"
    echo "Updated security group $sg_id to use VPC CIDR range for port $port."
  done
done
