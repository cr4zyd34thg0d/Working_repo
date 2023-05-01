#!/bin/bash
# file name: redshift_encryption_check.sh
# Finding: Redshift.10 Redshift clusters should be encrypted at rest
aws redshift describe-clusters |jq -r '.Clusters | .[] | [.ClusterIdentifier, .Encrypted] | @csv' | while IFS=, read -r cluster_name encrypted_status; do if [ "$encrypted_status" == "false" ]; then aws redshift modify-cluster --cluster-identifier "$cluster_name" --encrypted; fi done