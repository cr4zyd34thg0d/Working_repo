#!/bin/bash
# encrypt_kinesis_streams.sh
# Finding: Kinesis.1 Kinesis streams should be encrypted at rest

streams=$(aws kinesis list-streams --output text)
while read -r stream; do
  aws kinesis update-stream --stream-name $stream --encryption-type KMS --key-id alias/aws/kinesis --encryption-key-type AWS_OWNED
done <<< "$streams"