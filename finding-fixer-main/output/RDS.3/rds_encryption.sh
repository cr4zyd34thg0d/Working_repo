#!/bin/bash
# filename: rds_encryption.sh
# Finding: RDS.3 RDS DB instances should have encryption at-rest enabled
aws rds describe-db-instances | grep -i -E 'DBInstanceIdentifier|StorageEncrypted' | awk -F '"' 'ORS=NR%2?"|":"\n"' | awk -F '|' '{print "aws rds modify-db-instance --db-instance-identifier="$2" --enable-storage-encrypted"}' | sed 's/"//g' | bash
