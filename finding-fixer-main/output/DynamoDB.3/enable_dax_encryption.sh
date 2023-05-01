#!/bin/bash
# filename: enable_dax_encryption.sh
# Finding: DynamoDB.3 DynamoDB Accelerator (DAX) clusters should be encrypted at rest

# loop through all DAX clusters
for cluster in $(aws dax describe-clusters --query "Clusters[].ClusterName" --output text);
do
  # check if encryption at rest is enabled
  encryption=$(aws dax describe-clusters --cluster-name $cluster --query "Clusters[].ServerSideEncryption.Enabled" --output text)
  if [[ "$encryption" == "False" ]]; then
    # enable encryption at rest
    aws dax update-cluster --cluster-name $cluster --server-side-encryption-disabled=false
  fi
done