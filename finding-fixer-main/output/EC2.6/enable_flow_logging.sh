#!/bin/bash
# enable_flow_logging.sh
# Finding: EC2.6 VPC flow logging should be enabled in all VPCs

for vpc_id in $(aws ec2 describe-vpcs | jq -r '.Vpcs[].VpcId')
do
  if ! aws ec2 describe-flow-logs --filter Name=resource-id,Values=$vpc_id --query 'FlowLogs[].FlowLogId' --output text >/dev/null 2>&1; then
    aws ec2 create-flow-logs --resource-type VPC --resource-id $vpc_id --traffic-type ALL --log-group-name "vpcflowlogs-${vpc_id}" --deliver-logs-permission-arn <insert_log_permissions_arn_here>
  fi
done