#!/bin/bash
# filename: review_and_configure_encryption.sh
# Finding: Opensearch.3 OpenSearch domains should encrypt data sent between nodes

# Loop through all OpenSearch domains
for domain in $(aws opensearch list-domain-names --output text --query 'DomainNames[*]')
do
    # Check if encryption is already enabled
    response=$(aws opensearch describe-domain --domain-name $domain --query 'DomainStatus.EncryptionAtRestOptions.Enabled')
    if [[ "$response" == "true" ]]; then
        # If encryption is already enabled, skip to next domain
        continue
    fi

    # If encryption is not enabled, configure it
    aws opensearch update-domain-config \
        --domain-name $domain \
        --encryption-at-rest-options '{"Enabled": true}' \
        --node-to-node-encryption-options '{"Enabled": true}'
done