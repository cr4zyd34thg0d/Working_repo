#!/bin/bash
# Filename: disable-vpc-default-sg-rules.sh
# Finding: EC2.2 The VPC default security group should not allow inbound and outbound traffic

aws ec2 revoke-security-group-ingress --group-id default --protocol all --port all --cidr 0.0.0.0/0
aws ec2 revoke-security-group-egress --group-id default --protocol all --port all --cidr 0.0.0.0/0