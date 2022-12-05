import json
import logging
import os

import boto3

logging.basicConfig(format='%(asctime)s %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p', level=logging.INFO)

client = boto3.client('ec2')

def lambda_handler(event, context):
    logging.info(str(event))

    try:
        snapshots = []
        response = client.describe_snapshots(
            MaxResults=1000,
            RestorableByUserIds=[
                'all',
            ],
            OwnerIds=[
                'self',
            ]
        )
        snapshots = response['Snapshots']

        while 'NextToken' in response.keys():
            response = client.describe_snapshots(
                MaxResults=1000,
                NextToken=response['NextToken'],
                RestorableByUserIds=[
                    'all',
                ],
                OwnerIds=[
                    'self',
                ]
            )
            snapshots.append(response['Snapshots'])

        logging.info(str(snapshots))

        for snapshot in snapshots:
            response = client.modify_snapshot_attribute(
                Attribute='createVolumePermission',
                CreateVolumePermission={
                    'Remove': [
                        {
                            'Group': 'all',
                        },
                    ]
                },
                SnapshotId=snapshot['SnapshotId'],
            )
        
        logging.info(str(response))
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
