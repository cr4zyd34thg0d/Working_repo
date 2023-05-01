#!/bin/bash
# filename: elasticache_encryption.sh
# Finding: ElastiCache.5 ElastiCache replication groups should have encryption-in-transit enabled

aws elasticache describe-replication-groups | jq '.ReplicationGroups[] | select(.TransitEncryption.Enabled == false) | .ReplicationGroupId' | while read -r rg
do
   aws elasticache modify-replication-group --replication-group-id "$rg" --transit-encryption Enabled=true
done