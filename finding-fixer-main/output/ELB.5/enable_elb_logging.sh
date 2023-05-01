#!/bin/bash
#
# Finding: ELB.5 Application and Classic Load Balancers logging should be enabled
# enable_elb_logging.sh
#
aws elbv2 describe-load-balancers | jq -r '.LoadBalancers[].LoadBalancerArn' | while read balancer
do
  aws elbv2 describe-load-balancer-attributes --load-balancer-arn $balancer | jq '.Attributes[]' | grep -q access_logs.s3.enabled || aws elbv2 modify-load-balancer-attributes --load-balancer-arn $balancer --attributes Key=access_logs.s3.enabled,Value=true
done

aws elb describe-load-balancers | jq -r '.LoadBalancerDescriptions[].LoadBalancerName' | while read balancer
do
  aws elb describe-load-balancer-attributes --load-balancer-name $balancer | jq '.LoadBalancerAttributes.AccessLog.Enabled' | grep -q true || aws elb modify-load-balancer-attributes --load-balancer-name $balancer --load-balancer-attributes "{\"AccessLog\":{\"Enabled\":true}}"
done