#!/bin/bash
# Filename: rds_monitoring.sh
# Finding: RDS.6 Enhanced monitoring should be configured for RDS DB instances
aws rds describe-db-instances --query "DBInstances[].[DBInstanceIdentifier,EnhancedMonitoringResourceArn]" --output text | while read -r db monitoring_resource; do
    if [ "$monitoring_resource" = "arn:aws:rds:$REGION:$ACCOUNT_ID:monitoring:db:$db" ]; then
        echo "Enhanced Monitoring is already configured for $db"
    else
        aws rds modify-db-instance --db-instance-identifier $db --monitoring-role-arn "arn:aws:iam::$ACCOUNT_ID:role/$IAM_ROLE" --monitoring-interval 60 --apply-immediately
        echo "Enhanced Monitoring configured for $db"
    fi
done