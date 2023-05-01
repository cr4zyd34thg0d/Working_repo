#!/bin/bash
# Filename: cloudfront_sni.sh
# Finding: CloudFront.8 CloudFront distributions should use SNI to serve HTTPS requests

# Set variable for CloudFront distributions
distributions=$(aws cloudfront list-distributions --query "DistributionList.Items[].Id" --output text)

# Loop through each distribution and update SSL configuration
for distro in $distributions
do
  aws cloudfront update-distribution --id $distro --viewer-protocol-policy "redirect-to-https" --default-cache-behavior "{\"ViewerProtocolPolicy\":\"redirect-to-https\",\"MinTTL\":0,\"AllowedMethods\":{\"Quantity\":7,\"Items\":[\"HEAD\",\"GET\",\"POST\",\"PUT\",\"PATCH\",\"OPTIONS\",\"DELETE\"]},\"SmoothStreaming\":false,\"DefaultTTL\":86400,\"MaxTTL\":31536000,\"Compress\":true,\"LambdaFunctionAssociations\":{\"Quantity\":0,\"Items\":[]},\"ForwardedValues\":{\"QueryString\":true,\"Headers\":{\"Quantity\":0,\"Items\":[]},\"Cookies\":{\"Forward\":\"none\"},\"QueryStringCacheKeys\":{\"Quantity\":0,\"Items\":[]}},\"TrustedSigners\":{\"Enabled\":false,\"Quantity\":0,\"Items\":[]},\"TargetOriginId\":\"S3-$distro\",\"ForwardedValues\":{\"QueryString\":false,\"Cookies\":{\"Forward\":\"none\"},\"Headers\":{\"Quantity\":0,\"Items\":[]}},\"ViewerCertificate\":{\"ACMCertificateArn\":\"arn:aws:acm:us-east-1:123456789012:certificate/abcd1234-abcd-1234-abcd-1234abcd5678\",\"SSLSupportMethod\":\"sni-only\",\"MinimumProtocolVersion\":\"TLSv1.2_2019\",\"Certificate\":\"arn:aws:acm:us-east-1:xxxxxxxxxxxx:certificate/abcdefgh-1234-5678-abcd-1234567890ab\",\"CertificateSource\":\"acm\"}}"
done