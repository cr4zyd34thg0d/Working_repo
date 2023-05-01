#!/bin/bash

# Finding: Config.1 AWS Config should be enabled

# This script looks at every region, verifies that AWS Config is enabled, and activates it otherwise.

# Get list of AWS regions
regions=$(aws ec2 describe-regions --query 'Regions[*].RegionName' --output text)

# Loop through each region
for region in $regions; do
  echo "Checking AWS Config status in region $region..."
  
  # Check if AWS Config is enabled in the region
  config_enabled=$(aws configservice describe-configuration-recorders --query 'ConfigurationRecorders[*].name' --output text --region "$region" 2>/dev/null)
  
  if [ -z "$config_enabled" ]; then
    # AWS Config is not enabled in the region, activate it
    echo "AWS Config is not enabled in region $region, activating it..."
    aws configservice put-configuration-recorder --configuration-recorder name=MyRecorder --recording-group allSupported --region "$region"
    aws configservice start-configuration-recorder --configuration-recorder-name MyRecorder --region "$region"
  else
    echo "AWS Config is enabled in region $region."
  fi
done
