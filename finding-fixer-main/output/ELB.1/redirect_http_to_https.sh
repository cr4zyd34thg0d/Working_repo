#!/bin/bash
# redirect_http_to_https.sh
# Finding: ELB.1 Application Load Balancer should be configured to redirect all HTTP requests to HTTPS
aws elbv2 modify-listener --listener-arn <listener-arn> --protocol HTTP --port 80 --default-actions Type=redirect,RedirectConfig="{Protocol=HTTPS,Port=443,StatusCode=HTTP_301}"