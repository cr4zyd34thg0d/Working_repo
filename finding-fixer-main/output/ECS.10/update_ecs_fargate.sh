#!/bin/bash
# update_ecs_fargate.sh
# Finding: ECS.10 ECS Fargate services should run on the latest Fargate platform version

# Get list of ECS services
services=$(aws ecs list-services --cluster <cluster_name> --region <region> --output text)

# Loop through each service and update it
for service in $services
do
  platform_version=$(aws ecs describe-services --services $service --cluster <cluster_name> --region <region> --query "services[0].platformVersion" --output text)
  latest_version=$(aws ecs describe-task-definition --task-definition $service --query "taskDefinition.containerDefinitions[0].image" --output text | cut -d ":" -f 2)
  
  if [ "$platform_version" != "$latest_version" ]; then
    echo "Updating service $service to latest platform version"
    aws ecs update-service --cluster <cluster_name> --service $service --platform-version $latest_version --region <region>
  fi
done