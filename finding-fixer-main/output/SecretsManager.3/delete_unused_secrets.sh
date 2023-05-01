#!/bin/bash


# Finding: SecretsManager.3 Remove unused Secrets Manager secrets
# This script deletes all secrets in Secrets Manager that have not been used and have been created more than N days ago.

# Get list of secret names
secrets=$(aws secretsmanager list-secrets --query 'SecretList[*].Name' --output text)

# Set default number of days to 180
days=180

# Check if the script was called with an argument for the number of days
if [ $# -gt 0 ]; then
  # Use the argument as the number of days
  days=$1
fi

# Calculate timestamp for the cutoff date
cutoff_ts=$(date -d "$days days ago" +"%s")

# Loop through each secret
for secret in $secrets; do
  echo "Checking Secrets Manager secret $secret..."
  
  # Get last access date of the secret
  last_access=$(aws secretsmanager describe-secret --secret-id "$secret" --query 'LastAccessedDate' --output text)
  
  if [ -z "$last_access" ]; then
    # Secret has never been accessed, check if it was created more than N days ago
    create_date=$(aws secretsmanager describe-secret --secret-id "$secret" --query 'CreatedDate' --output text)
    create_ts=$(date -d "$create_date" +"%s")
    if [ "$create_ts" -lt "$cutoff_ts" ]; then
      # Secret was created more than N days ago, delete it
      echo "Secret $secret has never been accessed and was created more than $days days ago, deleting it..."
      aws secretsmanager delete-secret --secret-id "$secret"
    else
      echo "Secret $secret has never been accessed but was created less than $days days ago."
    fi
  else
    # Calculate number of days since last access
    last_access_ts=$(date -d "$last_access" +"%s")
    now_ts=$(date +"%s")
    diff=$(( (now_ts - last_access_ts) / (24*60*60) ))
    
    if [ "$diff" -ge "$days" ]; then
      # Secret has not been accessed in N days or more, delete it
      echo "Secret $secret has not been accessed in $diff days and was created more than $days days ago, deleting it..."
      aws secretsmanager delete-secret --secret-id "$secret"
    else
      echo "Secret $secret has been accessed within the last $diff days."
    fi
  fi
done
