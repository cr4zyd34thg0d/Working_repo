#!/bin/bash

# Finding: Opensearch.7 OpenSearch domains should have fine-grained access control enabled
# Filename: openserach-fine-grained-access.sh

aws configure set region YOUR_REGION

for domain in $(aws opensearch list-domain-names --output text --query 'DomainNames[*].DomainName'); do
  domain_config=$(aws opensearch describe-domain --domain-name "$domain")
  access_policies=$(echo "$domain_config" | jq -r '.DomainStatus.AccessPolicies')
  if [[ "$access_policies" == "null" ]]; then
    echo "Enabling fine-grained access control for domain $domain"
    aws opensearch update-domain-config --domain-name "$domain" --advanced-security-options 'Enabled=true,InternalUserDatabaseEnabled=true'
  else
    echo "Fine-grained access control already enabled for domain $domain"
  fi
done