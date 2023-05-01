#!/bin/bash

# join-org.sh

# Finding: Account.2 AWS accounts should be part of an AWS Organizations organization

echo "Checking if account is part of AWS Organizations organization..."
if ! aws organizations describe-organization > /dev/null 2>&1; then
    echo "Account is not part of an AWS Organizations organization."
    echo "Please enter the ID of the organization you wish to join: "
    read org_id
    aws organizations invite-account-to-organization --target "{'Id': '${org_id}', 'Type': 'ORGANIZATION'}"
    echo "An invitation to join the organization has been sent to the account. Please check your email for further instructions."
else
    echo "Account is part of an AWS Organizations organization."
fi