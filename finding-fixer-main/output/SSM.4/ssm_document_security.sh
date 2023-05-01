#!/bin/bash
#filename: ssm_document_security.sh
# Finding: SSM.4 SSM documents should not be public

#List all SSM documents
documents=$(aws ssm list-documents --output text --query 'DocumentIdentifiers[].Name')

#Loop through each document and remove public permission
for doc in $documents
do
  aws ssm modify-document-permission --name $doc --permission-type Private
done