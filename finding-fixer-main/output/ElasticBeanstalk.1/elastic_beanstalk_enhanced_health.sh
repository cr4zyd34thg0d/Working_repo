#!/bin/bash
# filename: elastic-beanstalk-enhanced-health.sh
# Finding: ElasticBeanstalk.1 Elastic Beanstalk environments should have enhanced health reporting enabled

# Enabling enhanced health reporting for Elastic Beanstalk environments
aws elasticbeanstalk list-environments --query 'Environments[].EnvironmentName' --output text | while read env_name; do
    aws elasticbeanstalk update-environment --environment-name "$env_name" --option-settings Namespace="aws:elasticbeanstalk:healthreporting:system",OptionName="EnhancedHealthAuthEnabled",Value="true"
done