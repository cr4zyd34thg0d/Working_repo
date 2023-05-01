#!/bin/bash


# Filename: aws_contact_sync.sh

# Finding: Account.1 Security contact information should be provided for an AWS account

master_account_id="MASTER_ACCOUNT_ID"
master_contact=$(aws organizations describe-account --account-id $master_account_id | jq '.Account.Contact')
master_name=$(echo $master_contact | jq -r '.Name')
master_email=$(echo $master_contact | jq -r '.Email')
master_address=$(echo $master_contact | jq -r '.Address')

child_accounts=$(aws organizations list-accounts | jq -r '.Accounts[].Id')

for account_id in $child_accounts; do
  contact=$(aws organizations describe-account --account-id $account_id | jq '.Account.Contact')
  name=$(echo $contact | jq -r '.Name')
  email=$(echo $contact | jq -r '.Email')
  address=$(echo $contact | jq -r '.Address')

  if [[ -z "$name" || -z "$email" || -z "$address" ]]; then
    aws organizations create-account-alias --account-id $account_id --account-alias $name
    aws organizations enable-aws-service-access --service-principal support
    aws organizations register-delegated-administrator --account-id $account_id --service-principal delegated_admin_service_principal

    aws organizations enable-policy-type --root-id $master_account_id --policy-type "SERVICE_CONTROL_POLICY"
    aws organizations invite-account-to-organization --target $account_id --notes "Please fill out contact information"
    aws organizations create-policy --content "{\"Version\":\"2012-10-17\",\"Statement\":{\"Effect\":\"Deny\",\"Action\":[\"*\"],\"Resource\":\"*\"}}" --name "Deny All" --type "SERVICE_CONTROL_POLICY"

    aws organizations update-policy --policy-id "SERVICE_CONTROL_POLICY" --add-targets "Input={'TargetId': $account_id, 'Arn': 'arn:aws:organizations::$account_id:account/$account_id'}"
    aws organizations attach-policy --policy-id "SERVICE_CONTROL_POLICY" --target-id $account_id

    aws organizations update-account --account-id $account_id --name "$master_name" --email "$master_email" --address "$master_address"
  fi
done


----
Option 2


master_account=$(aws organizations list-accounts --output json | jq '.Accounts[] | select(.JoinedTimestamp != null) | select(.Status == "ACTIVE") | select(.Name == "Master Account") | .Id' | tr -d '"')

master_info=$(aws organizations describe-account --account-id $master_account --output json)

name=$(echo $master_info | jq -r '.Account.Name')
email=$(echo $master_info | jq -r '.Account.Email')
address=$(echo $master_info | jq -r '.Account.Address')

child_accounts=$(aws organizations list-accounts --output json | jq '.Accounts[] | select(.JoinedTimestamp != null) | select(.Status == "ACTIVE") | select(.Name != "Master Account") | .Id' | tr -d '"')

for account in $child_accounts; do
  account_info=$(aws organizations describe-account --account-id $account --output json)
  if [[ -z $(echo $account_info | jq -r '.Account.Name') ]]; then
    aws organizations create-account-contact --account-id $account --name $name --email $email --address $address
  fi
done
