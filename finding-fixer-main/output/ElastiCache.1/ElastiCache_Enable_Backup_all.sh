#!/bin/bash

# Finding: ElastiCache.1 ElastiCache Redis clusters should have automatic backup enabled

# This script reviews ElastiCache Redis clusters and ensures automatic backup is enabled.

# Get list of Redis clusters
redis_clusters=$(aws elasticache describe-cache-clusters --query 'CacheClusters[?Engine==`redis`].CacheClusterId' --output text)

# Loop through each Redis cluster
for cluster_id in $redis_clusters; do
  echo "Checking Redis cluster $cluster_id..."
  
  # Check if automatic backup is enabled
  backup_enabled=$(aws elasticache describe-cache-cluster --cache-cluster-id "$cluster_id" --query 'CacheClusters[0].AutomaticBackupRetentionDays' --output text)
  
  if [ "$backup_enabled" == "0" ]; then
    # Automatic backup is not enabled, enable it
    echo "Automatic backup is not enabled for Redis cluster $cluster_id, enabling it..."
    aws elasticache modify-cache-cluster --cache-cluster-id "$cluster_id" --automatic-backup-retention-period 7
  else
    echo "Automatic backup is enabled for Redis cluster $cluster_id."
  fi
done
