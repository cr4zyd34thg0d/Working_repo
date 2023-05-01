#!/bin/bash
# filename: trail_config.sh
# Finding: CloudTrail.1 CloudTrail should be enabled and configured with at least one multi-Region trail that includes read and write management events

aws cloudtrail describe-trails --output text | grep -q 'Name: <your-trail-name>'
if [ $? -ne 0 ]
then
    aws cloudtrail create-trail --name <your-trail-name> --s3-bucket-name <your-s3-bucket-name> --is-multi-region-trail --include-global-service-events
fi

aws cloudtrail update-trail --name <your-trail-name> --is-multi-region-trail --include-global-service-events --enable-log-file-validation --is-organization-trail

aws cloudtrail put-event-selectors --trail-name <your-trail-name> --event-selectors file://event-selectors.json

aws cloudtrail start-logging --name <your-trail-name>