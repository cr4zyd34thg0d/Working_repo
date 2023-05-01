#!/bin/bash
#filename: cloudfront_encryption.sh
# Finding: CloudFront.9 CloudFront distributions should encrypt traffic to custom origins

#List all CloudFront distributions
aws cloudfront list-distributions --query 'DistributionList.Items[*].{ID:Id}'

#Enable encryption of traffic to custom origins
aws cloudfront update-distribution --id <DistributionID> --origin-ssl-protocols TLSv1.2 --query 'Distribution.Status'