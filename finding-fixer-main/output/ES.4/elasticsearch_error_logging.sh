#!/bin/bash
#filename: elasticsearch_error_logging.sh
# Finding: ES.4 Elasticsearch domain error logging to CloudWatch Logs should be enabled


# Set CloudWatch log group ARN
cloudwatch_log_group_arn=<CloudWatchLogGroupArn>

# List of Elasticsearch domain names to update
domains="$(aws es list-domain-names --output=text --query 'DomainNames[]')"


# Loop over each domain and update log publishing options as needed
for domain in "${domains[@]}"
do
    # Check if ES_APPLICATION_LOGS need updating
    aws es describe-elasticsearch-domain-configuration --domain-name $domain| jq '.DomainConfig.LogPublishingOptions' | grep -q '"ES_APPLICATION_LOGS":{"CloudWatchLogsLogGroupArn":null}' && \
    aws es update-elasticsearch-domain-config --domain-name $domain --log-publishing-options "{\"ES_APPLICATION_LOGS\":{\"CloudWatchLogsLogGroupArn\":\"$cloudwatch_log_group_arn\"}}"

    # Check if INDEX_SLOW_LOGS need updating
    aws es describe-elasticsearch-domain-configuration --domain-name $domain| jq '.DomainConfig.LogPublishingOptions' | grep -q '"INDEX_SLOW_LOGS":{"CloudWatchLogsLogGroupArn":null}' && \
    aws es update-elasticsearch-domain-config --domain-name $domain --log-publishing-options "{\"INDEX_SLOW_LOGS\":{\"CloudWatchLogsLogGroupArn\":\"$cloudwatch_log_group_arn\"}}"

    # Check if SEARCH_SLOW_LOGS need updating
    aws es describe-elasticsearch-domain-configuration --domain-name $domain| jq '.DomainConfig.LogPublishingOptions' | grep -q '"SEARCH_SLOW_LOGS":{"CloudWatchLogsLogGroupArn":null}' && \
    aws es update-elasticsearch-domain-config --domain-name $domain --log-publishing-options "{\"SEARCH_SLOW_LOGS\":{\"CloudWatchLogsLogGroupArn\":\"$cloudwatch_log_group_arn\"}}"

    # Check if AUDIT_LOGS need updating
    aws es describe-elasticsearch-domain-configuration --domain-name $domain| jq '.DomainConfig.LogPublishingOptions' | grep -q '"AUDIT_LOGS":{"CloudWatchLogsLogGroupArn":null}' && \
    aws es update-elasticsearch-domain-config --domain-name $domain --log-publishing-options "{\"AUDIT_LOGS\":{\"CloudWatchLogsLogGroupArn\":\"$cloudwatch_log_group_arn\"}}"
done
