#!/bin/bash
#filename: enable_deletion_protection.sh
# Finding: RDS.8 RDS DB instances should have deletion protection enabled

for instance_id in $(aws rds describe-db-instances --query 'DBInstances[*].DBInstanceIdentifier' --output=text);
do
    deletion_protection=$(aws rds describe-db-instances --db-instance-identifier $instance_id --query 'DBInstances[*].DeletionProtection' --output=text)
    if [ $deletion_protection == "False" ]
    then
        aws rds modify-db-instance --db-instance-identifier $instance_id --deletion-protection
    fi
done