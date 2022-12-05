import json
import logging
import os

import boto3

logging.basicConfig(format='%(asctime)s %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p', level=logging.INFO)

def lambda_handler(event, context):
    logging.info(str(event))

    regions = ['us-east-1','us-east-2','us-west-2']
    for region in regions:
        # cross-region
        rds_client = boto3.client('rds', region_name=region)
        backup_client = boto3.client('backup',region_name=region)

        try:
            database_id = event['parameterValue']
            response = rds_client.describe_db_clusters(
                DBClusterIdentifier=database_id,
                MaxRecords=100,
                IncludeShared=False
            )
            database_arn = response['DBClusters'][0]['DBClusterArn']
            response = backup_client.start_backup_job(
                BackupVaultName=os.environ['BACKUP_VAULT'],
                ResourceArn=database_arn,
                IamRoleArn=os.environ['BACKUP_IAM_ROLE'],
            )
        except Exception as e:
            logging.error(str(e))
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
