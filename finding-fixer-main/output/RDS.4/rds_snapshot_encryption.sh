#!/bin/bash
#filename: rds_snapshot_encryption.sh
# Finding: RDS.4 RDS cluster snapshots and database snapshots should be encrypted at rest

for cluster in $(aws rds describe-db-clusters --query 'DBClusters[].DBClusterIdentifier' --output text); do
    for snapshot in $(aws rds describe-db-cluster-snapshots --db-cluster-identifier $cluster --query 'DBClusterSnapshots[].DBClusterSnapshotIdentifier' --output text); do
        if [ "$(aws rds describe-db-cluster-snapshot-attributes --db-cluster-snapshot-identifier $snapshot --query 'DBClusterSnapshotAttributesResult.DBClusterSnapshotAttributes[].AttributeValue | [0]' --output text)" != "true" ]; then
            aws rds modify-db-cluster-snapshot-attribute --db-cluster-snapshot-identifier $snapshot --attribute-name "encrypted" --values "true"
        fi
    done
done

for db in $(aws rds describe-db-instances --query 'DBInstances[].DBInstanceIdentifier' --output text); do
    for snapshot in $(aws rds describe-db-snapshots --db-instance-identifier $db --query 'DBSnapshots[].DBSnapshotIdentifier' --output text); do
        if [ "$(aws rds describe-db-snapshot-attributes --db-snapshot-identifier $snapshot --query 'DBSnapshotAttributesResult.DBSnapshotAttributes[].AttributeValue | [0]' --output text)" != "true" ]; then
            aws rds modify-db-snapshot-attribute --db-snapshot-identifier $snapshot --attribute-name "encrypted" --values "true"
        fi
    done
done