#!/bin/bash
# check_redshift_connections.sh
# Finding: Redshift.2 Connections to Amazon Redshift clusters should be encrypted in transit
aws redshift describe-clusters | jq '.Clusters[].Endpoint.Address' | while read cluster; do
    aws redshift describe-hsm-configurations --query "HsmConfigurations[*].ExternalId[]" | while read externalid; do
        aws redshift describe-connections --query "Connections[*].Status[]" --cluster-identifier "$cluster" --hsm-client-certificate-identifier "$externalid" --output text | grep -v -q "Connection details encrypted by HSM" && echo "Cluster $cluster has unencrypted connections"
    done
done