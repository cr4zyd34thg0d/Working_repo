#!/bin/bash
# filename: aws_cache_encryption.sh
# Finding: APIGateway.5 API Gateway REST API cache data should be encrypted at rest

aws apigateway get-rest-apis | jq '.items[] | {id: .id, name: .name}' | while read -r result; do
  id=$(echo "$result" | jq -r '.id')
  name=$(echo "$result" | jq -r '.name')
  echo "Reviewing cache data for REST API \"$name\" (ID: $id)"
  if aws apigateway get-rest-api-cache \
    --rest-api-id "$id" \
    --output json \
    | jq -e '.type' >/dev/null
  then
    echo "Cache is enabled for REST API \"$name\" (ID: $id)"
    if ! aws apigateway get-rest-api-cache \
      --rest-api-id "$id" \
      --output json \
      | jq .cacheClusterEnabled
    then
      echo "Cache clustering is NOT enabled for REST API \"$name\" (ID: $id)"
    fi
  else
    echo "Cache is DISABLED for REST API \"$name\" (ID: $id)"
  fi
  
  if aws apigateway get-rest-api \
    --rest-api-id "$id" \
    --query 'binaryMediaTypes' \
    --output json | grep -q 'application/octet-stream'; then
    echo "Encryption for binary media types is ENABLED for REST API \"$name\" (ID: $id)"
  else
    echo "Encryption for binary media types is DISABLED for REST API \"$name\" (ID: $id)"
  fi
done