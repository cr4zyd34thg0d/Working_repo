#!/bin/bash
# enable_backtracking.sh
# Finding: RDS.14 Amazon Aurora clusters should have backtracking enabled

aws rds describe-db-clusters --query 'DBClusters[*].DBClusterIdentifier' --output text | while read line 
do 
  aws rds modify-db-cluster --db-cluster-identifier $line --enable-backtrack
done