#!/bin/bash

# Finding: IAM.18 Ensure a support role has been created to manage incidents with AWS Support
#Filename: create_support_role.sh
aws iam create-role \
--role-name support-role \
--assume-role-policy-document file://support-role-policy.json

aws iam attach-role-policy \
--role-name support-role \
--policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole 

aws iam put-role-policy \
--role-name support-role \
--policy-name support-policy \
--policy-document file://support-policy.json