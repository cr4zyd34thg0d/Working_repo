#!/bin/bash
# renew_certificates.sh
# Finding: ACM.1 Imported and ACM-issued certificates should be renewed after a specified time period
aws acm list-certificates --query 'CertificateSummaryList[].[CertificateArn]' --output text | while read -r line; do
    if aws acm describe-certificate --certificate-arn $line | grep -q "NOT_AFTER\|REVOKED"; then
        aws acm renew-certificate --certificate-arn $line
    fi
done