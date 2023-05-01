#!/bin/bash

# Finding: ECS.12 ECS clusters should use Container Insights
# Filename: ecs_container_insights.sh

aws ecs list-clusters | jq -r '.clusterArns[]' | while read arn; do
    status=$(aws ecs describe-clusters --cluster $arn | jq -r '.clusters[0].settings[] | select(.name=="containerInsights").value')
    if [ "$status" != "enabled" ]; then
        aws ecs put-account-setting --name "containerInsights" --value "enabled"
        echo "Enabled Container Insights for $arn"
    fi
done