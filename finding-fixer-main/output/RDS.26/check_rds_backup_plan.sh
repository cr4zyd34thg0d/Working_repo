#!/bin/bash
# check_rds_backup_plan.sh
# Finding: RDS.26 RDS DB instances should be covered by a backup plan
aws rds describe-db-instances --query 'DBInstances[].DBInstanceIdentifier' --output text | while read db_instance; do
  aws rds describe-db-instance-automated-backups --db-instance-identifier "$db_instance" --query 'DBInstanceAutomatedBackups[].Status' --output text | grep -q -E 'available|creating' || echo "Missing backup plan for $db_instance"
done