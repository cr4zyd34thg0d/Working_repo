#!/bin/bash
# filename: elasticsearch_audit_logging.sh
# Finding: ES.5 Elasticsearch domains should have audit logging enabled

domains="$(aws es list-domain-names --output=text --query 'DomainNames[]')"
for domain in $domains; do
  auditlogging="$(aws es describe-elasticsearch-domain --domain-name "$domain" --output=json --query 'DomainStatus.AuditLogOptions.AuditLogEnabled')"
  if [ "$auditlogging" = "false" ]; then
    aws es update-elasticsearch-domain-config --domain-name "$domain" --advanced-security-options 'AuditLogOptions={AuditLogEnabled=true}'
  fi
done