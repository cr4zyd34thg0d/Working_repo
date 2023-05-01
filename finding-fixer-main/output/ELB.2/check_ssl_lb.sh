#!/bin/bash
# check_ssl_lb.sh
# Finding: ELB.2 Classic Load Balancers with SSL/HTTPS listeners should use a certificate provided by AWS Certificate Manager

for lb in $(aws elb describe-load-balancers --query 'LoadBalancerDescriptions[*].LoadBalancerName' --output text); do
  for listener in $(aws elb describe-load-balancers --load-balancer-name $lb --query 'LoadBalancerDescriptions[*].ListenerDescriptions[?Listener.Protocol==`HTTPS` && ends_with(Listener.Protocol, `S`)].Listener.LoadBalancerPort' --output text); do
    cert_arn=$(aws elb describe-load-balancer-policy-types --load-balancer-name $lb --query 'PolicyTypeDescriptions[?PolicyTypeName==`SSLNegotiationPolicyType`].PolicyAttributeTypeDescriptions[?AttributeName==`Reference-Security-Policy`].AttributeValue' --output text)
    if [[ $cert_arn == arn:aws:acm:* ]]; then
      echo "Certificate found for $lb HTTPS listener $listener"
    else
      echo "Need to update $lb HTTPS listener $listener to use certificate from ACM"
    fi
  done
done