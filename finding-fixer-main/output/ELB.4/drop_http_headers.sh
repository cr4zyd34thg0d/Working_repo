#!/bin/bash
#filename: drop_http_headers.sh
# Finding: ELB.4 Application Load Balancer should be configured to drop http headers

#Reviewing Application Load Balancer settings
aws elbv2 describe-load-balancers --names my-alb --query "LoadBalancers[].{ARN:LoadBalancerArn, TargetGroups:TargetGroups[].TargetGroupArn, VpcId:VpcId, Subnets:AvailabilityZones[].SubnetId}"

#Configuring to drop http headers
aws elbv2 modify-load-balancer-attributes --load-balancer-arn my-alb-arn --attributes Key=http.drop_invalid_header_fields.enabled,Value=true

#Note: Replace 'my-alb' and 'my-alb-arn' with your respective application load balancer name and ARN.