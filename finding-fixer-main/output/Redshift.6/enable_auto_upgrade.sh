#!/bin/bash
# enable_auto_upgrade.sh
# Finding: Redshift.6 Amazon Redshift should have automatic upgrades to major versions enabled
aws redshift describe-clusters | jq '.Clusters[].ClusterIdentifier' | while read cluster; do
  echo "Enabling automatic upgrade for cluster $cluster"
  aws redshift modify-cluster --cluster-identifier $cluster --allow-version-upgrades --no-allow-version-upgrades-per-minor-version --apply-immediately
done