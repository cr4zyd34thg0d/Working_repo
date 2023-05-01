#!/bin/bash
# filename: tag_rds_snapshots.sh
# Finding: RDS.17 RDS DB instances should be configured to copy tags to snapshots

# Set the region
export AWS_DEFAULT_REGION=us-west-2

# List all RDS instances
INSTANCES=$(aws rds describe-db-instances --query 'DBInstances[*].DBInstanceIdentifier' --output text)

# Loop through each instance
for INSTANCE in $INSTANCES
do
  # Get the instance's ARN
  ARN=$(aws rds describe-db-instances --db-instance-identifier $INSTANCE --query 'DBInstances[0].DBInstanceArn' --output text)
  
  # Copy tags from instance to snapshots
  aws rds add-tags-to-resource --resource-name $ARN --tags $(aws rds list-tags-for-resource --resource-name $ARN --query 'TagList[*]' --output text)
done