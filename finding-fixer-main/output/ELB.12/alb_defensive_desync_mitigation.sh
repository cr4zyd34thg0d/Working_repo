#!/bin/bash
#Filename: alb-defensive-desync-mitigation.sh
# Finding: ELB.12 Application Load Balancer should be configured with defensive or strictest desync mitigation mode

aws elbv2 modify-load-balancer-attributes --load-balancer-arn YOUR_LOAD_BALANCER_ARN --attributes Key=defualt.defense-in-depth.enabled,Value=true Key=app.desync.mitigation.mode,Value=strictest