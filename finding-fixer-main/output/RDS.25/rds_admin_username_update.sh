#!/bin/bash
# filename: rds_admin_username_update.sh
# Finding: RDS.25 RDS database instances should use a custom administrator username

aws rds describe-db-instances | jq -r '.DBInstances[].DBInstanceIdentifier' | while read id; do
  aws rds modify-db-instance \
    --db-instance-identifier "$id" \
    --master-username new_username \
    --apply-immediately
done