#!/bin/bash

# Finding: EKS.2 EKS clusters should run on a supported Kubernetes version

# This script reviews EKS clusters and ensures that their version is at least at the configured version number, and updates it otherwise.

# Set the minimum version number to compare against
minimum_version="1.21"

# Get list of EKS clusters
clusters=$(aws eks list-clusters --query 'clusters' --output text)

# Loop through each cluster
for cluster in $clusters; do
  echo "Checking EKS cluster $cluster..."
  
  # Get current version of the cluster
  current_version=$(aws eks describe-cluster --name "$cluster" --query 'cluster.version' --output text)
  
  if (( $(echo "$current_version >= $minimum_version" | bc -l) )); then
    echo "EKS cluster $cluster is at least at version $minimum_version."
  else
    # Update the cluster version
    echo "EKS cluster $cluster is at version $current_version, updating to at least version $minimum_version..."
    aws eks update-cluster-version --name "$cluster" --version "$minimum_version"
  fi
done
