import json
import logging
import os
import string

import boto3

logging.basicConfig(format='%(asctime)s %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p', level=logging.INFO)

ec2 = boto3.resource('ec2')

def lambda_handler(event, context):
    logging.info(str(event))
    network_acl = ec2.NetworkAcl(event['parameterValue'])

    try:
        if network_acl:
            print(network_acl)
            bad_ports = [22,3389]
            bad_protocol = [-1]
            rule_exclusion = [110,120,510,520,550,32767]
            bad_cidr = ['0.0.0.0/0']
            print(network_acl.entries)
            for entry in network_acl.entries:
                print(entry)
                rule_number = int(entry['RuleNumber'])
                protocol = int(entry['Protocol'])
                port_range_to = int(entry['PortRange']['To']) if "PortRange" in entry else 0
                port_range_from = int(entry['PortRange']['From']) if "PortRange" in entry else 0
                egress = bool(entry['Egress'])
                allow_rule = True if entry['RuleAction'].lower() == 'allow' else False
                cidr = entry['CidrBlock']
                if (protocol in bad_protocol or (port_range_from <= 22 <= port_range_to or port_range_from <= 3389 <= port_range_to)) and cidr in bad_cidr and rule_number not in rule_exclusion and not egress and allow_rule:
                    response = network_acl.delete_entry(
                       DryRun=False,
                       Egress=False,
                       RuleNumber=rule_number
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