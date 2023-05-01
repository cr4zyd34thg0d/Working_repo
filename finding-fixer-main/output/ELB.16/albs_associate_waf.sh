#!/bin/bash
# filename: albs_associate_waf.sh
# Finding: ELB.16 Application Load Balancers should be associated with an AWS WAF web ACL
aws elbv2 describe-load-balancers --query "LoadBalancers[].[LoadBalancerArn]" --output text | while read arn; do
  if [ -z "$(aws elbv2 describe-rules --listener-arn $(aws elbv2 describe-listeners --load-balancer-arn $arn --query "Listeners[].[ListenerArn]" --output text) --query "Rules[].Predicates[].DataId" --output text | grep -E '^arn:aws:waf')" ]; then
    aws elbv2 modify-web-acl --web-acl-arn $(aws waf-regional create-web-acl --name my_web_acl --metric-name my_web_acl --output text --region us-west-2) --resource-arn $arn
  fi
done