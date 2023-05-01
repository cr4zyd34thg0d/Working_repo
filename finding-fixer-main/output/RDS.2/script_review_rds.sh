#!/bin/bash
# script_review_rds.sh
# Finding: RDS.2 RDS DB Instances should prohibit public access, as determined by the PubliclyAccessible configuration

aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier]' --output text | while read DB_INSTANCE; do
    PUBLIC_ACCESS=$(aws rds describe-db-instances --db-instance-identifier $DB_INSTANCE --query 'DBInstances[*].[PubliclyAccessible]' --output text)
    if [ "$PUBLIC_ACCESS" == "True" ]; then
        aws rds modify-db-instance --db-instance-identifier $DB_INSTANCE --no-publicly-accessible
    fi
done