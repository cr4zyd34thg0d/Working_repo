#!/bin/bash
#enable_deletion_protection.sh
# Finding: ELB.6 Application Load Balancer deletion protection should be enabled

for balancer in $(aws elbv2 describe-load-balancers --query "LoadBalancers[*].LoadBalancerArn" --output text); do
    deletion_protection=$(aws elbv2 describe-load-balancers --load-balancer-arns $balancer --query "LoadBalancers[*].LoadBalancerAttributes[*].Value" --output text | grep -oP '(?<=deletion_protection.enabled": )[^,]*')
    if [ $deletion_protection = "false" ]; then
        aws elbv2 modify-load-balancer-attributes --load-balancer-arn $balancer --attributes Key=deletion_protection.enabled,Value=true
    fi
done