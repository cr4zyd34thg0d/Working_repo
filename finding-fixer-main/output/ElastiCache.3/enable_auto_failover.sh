#!/bin/bash
# enable_auto_failover.sh
# Finding: ElastiCache.3 ElastiCache replication groups should have automatic failover enabled
aws elasticache describe-replication-groups --query "ReplicationGroups[*].{ID:ReplicationGroupId, AF:AutomaticFailover}" --output table | grep -v "True" | awk '{print $2}' | while read group;
do
   aws elasticache modify-replication-group --replication-group-id "$group" --automatic-failover-enabled;
done