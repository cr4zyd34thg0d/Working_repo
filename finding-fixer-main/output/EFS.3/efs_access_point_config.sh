#!/bin/bash
# efs_access_point_config.sh
# Finding: EFS.3 EFS access points should enforce a root directory
aws efs describe-access-points --query "AccessPoints[*].AccessPointId" --output text | while read -r ap_id; do
    aws efs update-access-point --access-point-id "$ap_id" --posix-user "gid=0,mountoptions=ro,uid=0" --root-directory "Path=/" --tags Key=RootDirectory,Value=Enforced
done