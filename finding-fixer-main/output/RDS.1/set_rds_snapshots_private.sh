#!/bin/bash
# set_rds_snapshots_private.sh
# Finding: RDS.1 RDS snapshot should be private

aws rds modify-db-snapshot-attribute --attribute-name "restore" --values-to-add "all" --db-snapshot-identifier "arn:aws:rds:us-east-1:123456789012:snapshot:my-db-snapshot" --region "us-east-1" --profile "my-aws-profile"