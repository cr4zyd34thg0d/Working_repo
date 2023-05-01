#!/bin/bash
# enable_audit_logging.sh
# Finding: Redshift.4 Amazon Redshift clusters should have audit logging enabled
aws redshift describe-clusters --query 'Clusters[*].{ID:ClusterIdentifier, Logging:LoggingEnabled}' | \
jq -r '.[] | select(.Logging == false).ID' | \
while read CLUSTER_NAME; do 
aws redshift modify-cluster \
--cluster-identifier $CLUSTER_NAME \
--logging-enabled \
--no-require-ssl \
--no-cluster-parameter-group-parameters \
--no-manual-snapshot-retention-period \
--no-snapshot-schedule \
--no-automated-snapshot-retention-period \
--no-preferred-maintenance-window \
--no-preferred-backup-window \
--no-allow-version-upgrade 
done