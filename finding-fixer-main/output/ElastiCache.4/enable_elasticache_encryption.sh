#!/bin/bash
# filename: enable-elasticache-encryption.sh
# Finding: ElastiCache.4 ElastiCache replication groups should have encryption-at-rest enabled

REP_GROUP_LIST=$(aws elasticache describe-cache-clusters --show-cache-node-info --query "CacheClusters[].ReplicationGroupId" --output text | sort -u)

for REP_GROUP in $REP_GROUP_LIST
do
  IS_ENCRYPTED=$(aws elasticache describe-replication-groups --replication-group-id $REP_GROUP --query "ReplicationGroups[].AuthTokenEnabled" --output text)

  if [ $IS_ENCRYPTED = "False" ]
  then
    aws elasticache modify-replication-group --replication-group-id $REP_GROUP --auth-token-enabled
  fi
done