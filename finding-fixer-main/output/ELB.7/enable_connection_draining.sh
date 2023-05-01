#!/bin/bash
# filename: enable-connection-draining.sh
# Finding: ELB.7 Classic Load Balancers should have connection draining enabled

# Loop through all classic load balancers
for lb in $(aws elb describe-load-balancers --query 'LoadBalancerDescriptions[*].LoadBalancerName' --output text); do
    # Check if connection draining is already enabled
    if ! aws elb describe-load-balancer-attributes --load-balancer-name $lb --query 'LoadBalancerAttributes.ConnectionDraining.Enabled' --output text | grep -q true; then
        # Enable connection draining if it's not already enabled
        aws elb modify-load-balancer-attributes --load-balancer-name $lb --load-balancer-attributes Key=connectionDraining.enabled,Value=true
    fi
done