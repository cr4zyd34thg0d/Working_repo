import json
import logging
import os

import boto3

logging.basicConfig(format='%(asctime)s %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p', level=logging.INFO)

client = boto3.client('logs')

def lambda_handler(event, context):
    logging.info(str(event))

    retention = os.environ['RETENTION']
    try:
        # payload = json.loads(event)
        logGroupID = event['parameterValue']
        response = client.put_retention_policy(
            logGroupName = logGroupID,
            retentionInDays=int(retention)
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
