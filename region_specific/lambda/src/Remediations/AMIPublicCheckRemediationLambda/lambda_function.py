import json
import logging
import os

import boto3

logging.basicConfig(format='%(asctime)s %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p', level=logging.INFO)

client = boto3.client('ec2')

def lambda_handler(event, context):
    logging.info(str(event))

    try:
        # payload = json.loads(event)
        account_id = event['parameterValue']
        public_ami_result = client.describe_images(
            Filters=[
                {
                    'Name': 'is-public',
                    'Values': ['true']
                }
                ],
            Owners=[account_id]
            )
        # If public_ami_list is not empty, generate non-compliant response
        if public_ami_result['Images']:
            for public_ami in public_ami_result['Images']:
                image_id = public_ami['ImageId']
                response = client.modify_image_attribute(
                    Attribute='launchPermission',
                    ImageId=image_id,
                    LaunchPermission={
                        'Remove': [
                            {
                                'Group': 'all'
                            },
                        ]
                    }
                )
    except Exception as e:
        logging.error(str(e))
        return {
            'statusCode': 500,
            'body': json.dumps(str(e))
        }

    logging.info(str(response))

    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
