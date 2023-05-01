#!/bin/bash
# check_cloudfront_s3_origins.sh
# Finding: CloudFront.12 CloudFront distributions should not point to non-existent S3 origins

aws cloudfront list-distributions --query 'DistributionList.Items[*].{Id:Id, Origins:Origins.Items[*].{DomainName: DomainName, Id: Id}}' | 
jq '.DistributionList.Items[] | select (.Origins != null) | select (.Origins[].DomainName | contains(".s3.amazonaws.com")) | select (.Origins[].Id | contains("S3")) | .Id' | 
xargs -I {} sh -c "aws cloudfront get-distribution-config --id {} | jq '.DistributionConfig.Origins.Items[].DomainName' | grep "'.s3.amazonaws.com'" || echo {} violates S3 origin check"