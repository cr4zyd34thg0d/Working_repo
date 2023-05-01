#!/bin/bash

# Finding: ElasticBeanstalk.2 Elastic Beanstalk managed platform updates should be enabled

# This script ensures that every Elastic Beanstalk environment has managed platform updates enabled.

# Get list of Elastic Beanstalk environments
environments=$(aws elasticbeanstalk describe-environments --query 'Environments[*].EnvironmentId' --output text)

# Loop through each environment
for environment in $environments; do
  echo "Checking Elastic Beanstalk environment $environment..."
  
  # Check if managed platform updates are enabled
  managed_updates=$(aws elasticbeanstalk describe-configuration-settings --environment-id "$environment" --query 'ConfigurationSettings[?OptionName==`ManagedActionsEnabled`].OptionValue' --output text)
  
  if [ "$managed_updates" != "true" ]; then
    # Managed platform updates are not enabled, enable them
    echo "Managed platform updates are not enabled for Elastic Beanstalk environment $environment, enabling them..."
    aws elasticbeanstalk update-environment --environment-id "$environment" --option-settings Namespace=aws:elasticbeanstalk:managedactions,OptionName=ManagedActionsEnabled,Value=true
  else
    echo "Managed platform updates are enabled for Elastic Beanstalk environment $environment."
  fi
done
