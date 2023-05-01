#!/bin/bash
# rds-admin-username.sh
# Finding: RDS.24 RDS Database Clusters should use a custom administrator username

# Set the custom username
USERNAME="admin"

# Iterate over each RDS Database Cluster
for CLUSTER in $(aws rds describe-db-clusters --query "DBClusters[].DBClusterIdentifier" --output text); do
  # Modify the cluster to use the custom username
  aws rds modify-db-cluster --db-cluster-identifier $CLUSTER --master-username $USERNAME
done