#!/bin/bash

# Finding: CodeBuild.5 CodeBuild project environments should not have privileged mode enabled

# This script reviews CodeBuild project environments and ensures privileged mode is disabled.

# Get list of CodeBuild projects
projects=$(aws codebuild list-projects --query 'projects' --output text)

# Loop through each project
for project in $projects; do
  echo "Checking CodeBuild project $project..."
  
  # Get project environment details
  environment=$(aws codebuild batch-get-projects --names "$project" --query 'projects[0].environment' --output json)
  
  # Check if privileged mode is enabled
  privileged_mode=$(echo "$environment" | jq -r '.privilegedMode')
  
  if [ "$privileged_mode" == "true" ]; then
    # Privileged mode is enabled, disable it
    echo "Privileged mode is enabled for CodeBuild project $project, disabling it..."
    aws codebuild update-project --name "$project" --environment-variables "name=PRIVILEGED_MODE,value=false,type=PLAINTEXT" --source-version "$LATEST" --buildspec-override '{"version":0,"phases":{"install":{"runtime-versions":{"docker":"18"}}},"artifacts":{"files":["**/*"],"name":"artifacts","discard-paths":"yes"}}'
  else
    echo "Privileged mode is disabled for CodeBuild project $project."
  fi
done
