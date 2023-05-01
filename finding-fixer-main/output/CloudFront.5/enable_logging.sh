#!/bin/bash
# enable-logging.sh
# Finding: CloudFront.5 CloudFront distributions should have logging enabled

# Iterate through all CloudFront distributions and enable logging if needed
aws cloudfront list-distributions --query "DistributionList.Items[*].{DomainName:DomainName, Logging:Logging.Enabled}" \
--output json | jq -c '.[] | select(.Logging == false) | {id: .DomainName} | "\(.id) "' | while read -r line
do
  aws cloudfront update-distribution --id "$line" --logging '{"Enabled":true,"IncludeCookies":false,"Bucket":"your-bucket-name","Prefix":"","FieldLevelEncryption":false}'
done