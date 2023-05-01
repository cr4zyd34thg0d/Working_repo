#!/bin/bash

# Finding: ES.8 Connections to Elasticsearch domains should be encrypted using TLS 1.2
# filename: encrypt_connections.sh

aws es update-elasticsearch-domain-config --domain-name YOUR_DOMAIN --elasticsearch-version "7.1" --tls-security-policy "Policy-Min-TLS-1-2-2019-07"