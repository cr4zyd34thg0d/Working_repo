#!/bin/bash
#create_elasticache_cluster.sh
# Finding: ElastiCache.7 ElastiCache clusters should not use the default subnet group
aws elasticache create-subnet-group --subnet-group-name CustomSubnetGroup --description "Custom subnet group for ElastiCache" --subnet-ids subnet-12345678 subnet-23456789 subnet-34567890
aws elasticache create-cache-cluster --cache-cluster-id my-cluster --engine memcached --cache-node-type cache.m3.medium --num-cache-nodes 2 --preferred-availability-zone us-west-2a --cache-subnet-group-name CustomSubnetGroup