#!/bin/bash
#file name: elasticsearch_encryption.sh
# Finding: ES.1 Elasticsearch domains should have encryption at-rest enabled

#Get a list of Elasticsearch domain names
domain_names=$(aws es list-domain-names --query "DomainNames[].DomainName" --output text)

#Loop through each domain name to check if encryption at-rest is enabled, and enable if not
for domain in $domain_names
do
  encrypt_status=$(aws es describe-elasticsearch-domain --domain-name $domain --query "DomainStatus.EncryptionAtRestOptions.Enabled")
  if [ "$encrypt_status" == "false" ]
  then
    aws es update-elasticsearch-domain-config --domain-name $domain --encryption-at-rest-options Enabled=true
  fi
done