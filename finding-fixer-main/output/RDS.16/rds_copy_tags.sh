#!/bin/bash
#Filename: rds-copy-tags.sh
# Finding: RDS.16 RDS DB clusters should be configured to copy tags to snapshots

#Reviewing all RDS DB clusters
for cluster in $(aws rds describe-db-clusters --query "DBClusters[].DBClusterIdentifier" --output text); do

  #Configuring to copy tags to snapshots
  aws rds modify-db-cluster --db-cluster-identifier $cluster --copy-tags-to-snapshot

done