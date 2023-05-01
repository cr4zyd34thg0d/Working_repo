#!/bin/bash
# Filename: check_elasticache_redis.sh
# Finding: ElastiCache.6 ElastiCache replication groups of earlier Redis versions should have Redis AUTH enabled

for group in $(aws elasticache describe-replication-groups | jq -r '.ReplicationGroups | .[] | select(.EngineVersion | contains("2.")).ReplicationGroupId')
do
  auth=$(aws elasticache describe-cache-parameters --cache-parameter-group-name default.redis2.8 | jq -r '.CacheParameters[].ParameterValue' | grep requirepass)

  if [[ -z $auth ]]
  then
    aws elasticache modify-cache-parameter-group --cache-parameter-group-name default.redis2.8 --parameter-name-values ParameterName=requirepass,ParameterValue="myRedisPassword" >/dev/null
    aws elasticache describe-cache-parameter-groups --cache-parameter-group-name default.redis2.8 | jq -r '.CacheParameterGroups | .[] | .CacheParameterGroupName + ": redis AUTH enabled."'
  else
    aws elasticache describe-cache-parameter-groups --cache-parameter-group-name default.redis2.8 | jq -r '.CacheParameterGroups | .[] | .CacheParameterGroupName + ": redis AUTH already enabled."'
  fi
done