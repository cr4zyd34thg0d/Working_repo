#!/bin/bash
# enable_encryption_at_rest.sh
# Finding: Opensearch.1 OpenSearch domains should have encryption at rest enabled
aws opensearch list-domains --query 'DomainNames[*].DomainName' --output text | while read -r LINE; do 
    aws opensearch update-domain --domain-name "$LINE" --advanced-security-options '{
        "EncryptionAtRestOptions": {
            "Enabled": true
        }
    }'
done