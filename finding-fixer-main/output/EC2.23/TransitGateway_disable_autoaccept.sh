#!/bin/bash

# Finding: EC2.23 EC2 Transit Gateways should not automatically accept VPC attachment requests

# This script ensures that every transit gateway does not have AutoAcceptSharedAttachments enabled.

# Get list of transit gateway IDs
tgw_ids=$(aws ec2 describe-transit-gateways --query 'TransitGateways[*].TransitGatewayId' --output text)

# Loop through each transit gateway
for tgw_id in $tgw_ids; do
  echo "Checking transit gateway $tgw_id..."
  
  # Check if AutoAcceptSharedAttachments is enabled
  auto_accept=$(aws ec2 describe-transit-gateway --transit-gateway-id "$tgw_id" --query 'TransitGateway.AutoAcceptSharedAttachments' --output text)
  
  if [ "$auto_accept" == "enabled" ]; then
    # AutoAcceptSharedAttachments is enabled, disable it
    echo "AutoAcceptSharedAttachments is enabled for transit gateway $tgw_id, disabling it..."
    aws ec2 modify-transit-gateway --transit-gateway-id "$tgw_id" --options '{"AutoAcceptSharedAttachments":"disable"}'
  else
    echo "AutoAcceptSharedAttachments is disabled for transit gateway $tgw_id."
  fi
done
