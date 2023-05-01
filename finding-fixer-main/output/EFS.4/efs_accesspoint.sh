#!/bin/bash
#filename: efs_accesspoint.sh
# Finding: EFS.4 EFS access points should enforce a user identity

#Iterating through all the EFS access points and setting the user identity based authentication
for access_point in $(aws efs describe-access-points --query "AccessPoints[*].AccessPointId" --output text)
do
  aws efs update-access-point --access-point-id $access_point --posix-user "Uid=1000,Gid=1000"
done