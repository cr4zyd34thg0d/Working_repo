#!/bin/bash

# Finding: Account.1 
# Filename: update_security_contact.sh


# Check if security contact information exists
aws organizations describe-account --query 'Account.ContactEmail' > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Security contact information already exists."
    exit 0
fi

# Prompt for security contact information
echo -n "Enter security contact email address: "
read email
echo -n "Enter security contact phone number: "
read phone

# Create security contact information
aws organizations register-delegated-administrator --service-principal securityhub --account-id $(aws sts get-caller-identity --query 'Account' --output text) --email $email --phone-number $phone
