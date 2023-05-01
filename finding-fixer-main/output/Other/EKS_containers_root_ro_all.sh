#!/bin/bash


# Finding: Other

# This script reviews EKS containers and ensures the root file system is read-only.

# Get list of EKS clusters
clusters=$(aws eks list-clusters --query 'clusters' --output text)

# Loop through each cluster
for cluster in $clusters; do
  echo "Checking EKS cluster $cluster..."
  
  # Get list of running pods in the cluster
  pod_list=$(kubectl get pods --all-namespaces --field-selector=status.phase=Running --output=jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name}{"\n"}{end}' --kubeconfig ~/.kube/config --context "$cluster" 2>/dev/null)
  
  # Loop through each pod
  while read -r pod; do
    namespace=$(echo "$pod" | awk '{print $1}')
    pod_name=$(echo "$pod" | awk '{print $2}')
    
    # Get pod spec
    pod_spec=$(kubectl get pod "$pod_name" -n "$namespace" --output json --kubeconfig ~/.kube/config --context "$cluster" 2>/dev/null)
    
    # Check if root file system is read-only
    read_only=$(echo "$pod_spec" | jq -r '.spec.containers[].securityContext?.readOnlyRootFilesystem')
    
    if [ "$read_only" != "true" ]; then
      # Root file system is not read-only, set it to read-only
      echo "Root file system is not read-only for pod $pod_name in namespace $namespace, setting it to read-only..."
      kubectl patch pod "$pod_name" -n "$namespace" --type=json -p='[{"op": "add", "path": "/spec/containers/0/securityContext", "value": {"readOnlyRootFilesystem": true}}]' --kubeconfig ~/.kube/config --context "$cluster" 2>/dev/null
    else
      echo "Root file system is read-only for pod $pod_name in namespace $namespace."
    fi
  done <<< "$pod_list"
done
