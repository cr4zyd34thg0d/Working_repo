#!/bin/bash
# elasticsearch_encryption.sh
# Finding: ES.3 Elasticsearch domains should encrypt data sent between nodes
aws es list-domain-names | jq -r '.DomainNames[].DomainName' | while read -r domain; do
  aws es describe-elasticsearch-domain --domain-name "$domain" | jq -e '.DomainStatus.EncryptionAtRestOptions.Enabled == true and .DomainStatus.NodeToNodeEncryptionOptions.Enabled == true' > /dev/null && echo "Domain $domain is using encryption between nodes and at rest."
done