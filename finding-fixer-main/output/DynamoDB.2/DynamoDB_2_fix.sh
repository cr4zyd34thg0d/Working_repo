#!/bin/bash
#enable_point_in_time_recovery.sh
# Finding: DynamoDB.2 DynamoDB tables should have point-in-time recovery enabled
aws dynamodb list-tables --output text | while read table; do
    recovery=$(aws dynamodb describe-table --table-name $table --query 'Table.PointInTimeRecoveryDescription.PointInTimeRecoveryStatus' --output text)
    if [ "$recovery" != "ENABLED" ]; then
        aws dynamodb update-continuous-backups --table-name $table --point-in-time-recovery-specification PointInTimeRecoveryEnabled=true
    fi
done