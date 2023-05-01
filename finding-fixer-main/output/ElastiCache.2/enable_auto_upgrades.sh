#!/bin/bash
# enable_auto_upgrades.sh
# Finding: ElastiCache.2 ElastiCache for Redis cache clusters should have auto minor version upgrades enabled

aws elasticache describe-cache-clusters --query "CacheClusters[?Engine=='redis'].{Id: CacheClusterId}" --output text | while read -r cluster_id; do
  aws elasticache modify-cache-cluster --cache-cluster-id "$cluster_id" --engine-version "5.0.0" --auto-minor-version-upgrade
done