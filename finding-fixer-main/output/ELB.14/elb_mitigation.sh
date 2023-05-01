#!/bin/bash

# Finding: ELB.14 Classic Load Balancer should be configured with defensive or strictest desync mitigation mode
# Filename: elb_mitigation.sh

aws elb describe-load-balancer-attributes --load-balancer-name my-load-balancer --attribute-names "CrossZoneLoadBalancing|ConnectionDraining|ConnectionSettings|IdleTimeout|AccessLog|ConnectionPools|ProxyProtocolV2"| jq '.LoadBalancerAttributes.ConnectionSettings.DesyncMitigationMode = "defensive"' | aws elb modify-load-balancer-attributes --load-balancer-name my-load-balancer --cli-input-json file://modified-attributes.json --output text

aws elb describe-load-balancer-attributes --load-balancer-name my-load-balancer --attribute-names "CrossZoneLoadBalancing|ConnectionDraining|ConnectionSettings|IdleTimeout|AccessLog|ConnectionPools|ProxyProtocolV2"| jq '.LoadBalancerAttributes.ConnectionSettings.DesyncMitigationMode = "strictest"' | aws elb modify-load-balancer-attributes --load-balancer-name my-load-balancer --cli-input-json file://modified-attributes.json --output text