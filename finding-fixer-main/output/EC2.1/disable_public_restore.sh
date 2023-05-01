#!/bin/bash

# Finding: EC2.1 EBS snapshots should not be publicly restorable
# Filename: disable_public_restore.sh

# Review all EBS snapshots and disable public restore if enabled
aws ec2 describe-snapshots --owner-ids self --query "Snapshots[*].{SnapshotId:SnapshotId, Public:Encrypted}" --output text | awk '/False/{print "aws ec2 modify-snapshot-attribute --snapshot-id " $1 " --attribute createVolumePermission --operation remove --user-ids all-users"}' | xargs -I {} sh -c "{}"