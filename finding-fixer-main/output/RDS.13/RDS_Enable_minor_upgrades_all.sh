#!/bin/bash

# Finding: RDS.13 RDS automatic minor version upgrades should be enabled

# This script reviews RDS instances and ensures minor version upgrades are enabled.

# Get list of RDS instance identifiers
instance_ids=$(aws rds describe-db-instances --query 'DBInstances[*].DBInstanceIdentifier' --output text)

# Loop through each instance
for instance_id in $instance_ids; do
  echo "Checking RDS instance $instance_id..."
  
  # Check if minor version upgrades are enabled
  minor_upgrades_enabled=$(aws rds describe-db-instances --db-instance-identifier "$instance_id" --query 'DBInstances[0].AutoMinorVersionUpgrade' --output text)
  
  if [ "$minor_upgrades_enabled" == "false" ]; then
    # Minor version upgrades are not enabled, enable them
    echo "Minor version upgrades are not enabled for RDS instance $instance_id, enabling them..."
    aws rds modify-db-instance --db-instance-identifier "$instance_id" --auto-minor-version-upgrade
  else
    echo "Minor version upgrades are enabled for RDS instance $instance_id."
  fi
done
