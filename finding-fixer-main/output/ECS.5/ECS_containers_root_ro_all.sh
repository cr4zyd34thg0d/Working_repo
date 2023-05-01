#!/bin/bash

# Finding: ECS.5 ECS containers should be limited to read-only access to root filesystems

# This script reviews ECS containers and ensures the root file system is read-only.

# Get list of ECS clusters
clusters=$(aws ecs list-clusters --query 'clusterArns' --output text)

# Loop through each cluster
for cluster_arn in $clusters; do
  cluster_name=$(basename "$cluster_arn")
  echo "Checking ECS cluster $cluster_name..."
  
  # Get list of running tasks in the cluster
  task_list=$(aws ecs list-tasks --cluster "$cluster_name" --desired-status RUNNING --query 'taskArns' --output text)
  
  # Loop through each task
  for task_arn in $task_list; do
    task_definition=$(aws ecs describe-tasks --cluster "$cluster_name" --tasks "$task_arn" --query 'tasks[0].taskDefinitionArn' --output text)
    container_list=$(aws ecs describe-task-definition --task-definition "$task_definition" --query 'taskDefinition.containerDefinitions[*]' --output json)
    
    # Loop through each container in the task
    for container in $container_list; do
      # Check if root file system is read-only
      read_only=$(echo "$container" | jq -r '.readonlyRootFilesystem')
      
      if [ "$read_only" != "true" ]; then
        # Root file system is not read-only, set it to read-only
        container_name=$(echo "$container" | jq -r '.name')
        echo "Root file system is not read-only for container $container_name in task $task_arn, setting it to read-only..."
        aws ecs register-task-definition --family "$(echo "$task_definition" | cut -d':' -f 6)" --revision "$(echo "$task_definition" | cut -d':' -f 7)" --container-definitions "[$(echo "$container_list" | jq "map(if .name==\"$container_name\" then .readonlyRootFilesystem=true else . end)")]" --query 'taskDefinition.taskDefinitionArn' --output text
      else
        echo "Root file system is read-only for container $container_name in task $task_arn."
      fi
    done
  done
done
