import json
import logging
import os
import string

import boto3

logging.basicConfig(format='%(asctime)s %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p', level=logging.INFO)

ec2 = boto3.resource('ec2')

def lambda_handler(event, context):
    logging.info(str(event))
    security_group = ec2.security_group(event['parameterValue'])

    try:
        if security_group:
            print(security_group)
            bad_cidr = ['0.0.0.0/0']
            print(security_group.entries)
            for entry in security_group.entries:
                group_id = int(entry['GroupId'])
                cidr = entry['CidrBlock']
                if (cidr in bad_cidr):
                    response = security_group.delete_entry(
                       DryRun=False,
                       GroupId='group_id'
                    )
    except Exception as e:
        logging.error(str(e))
        return {
            'statusCode': 500,
            'body': json.dumps(str(e))
        }


    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }