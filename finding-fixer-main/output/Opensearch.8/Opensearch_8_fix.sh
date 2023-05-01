#!/bin/bash
# set-tls-1.2.sh
# Finding: Opensearch.8 Connections to OpenSearch domains should be encrypted using TLS 1.2
aws opensearch set-tls-security-options --domain-name MY_DOMAIN --tls-1-2-enabled --no-tls-1-0-encrypted --no-tls-1-1-encrypted --node-to-node-encryption-enabled --tls-security-policy "Policy-Min-TLS-1-2-2021-01"