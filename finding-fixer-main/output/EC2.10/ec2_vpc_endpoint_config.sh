#!/bin/bash
#filename: ec2_vpc_endpoint_config.sh
# Finding: EC2.10 Amazon EC2 should be configured to use VPC endpoints that are created for the Amazon EC2 service

#Reviewing EC2 configuration
aws ec2 describe-instances

#Creating VPC endpoint for EC2 service
aws ec2 create-vpc-endpoint --vpc-endpoint-type Interface --service-name com.amazonaws.${AWS_REGION}.ec2 --vpc-id ${VPC_ID} --subnet-id ${SUBNET_ID} --security-group-id ${SECURITY_GROUP_ID}

#Enabling VPC endpoint for EC2 service
aws ec2 modify-vpc-endpoint --vpc-endpoint-id ${VPC_ENDPOINT_ID} --add-route-table-ids ${ROUTE_TABLE_ID}