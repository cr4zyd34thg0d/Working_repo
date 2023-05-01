#!/bin/bash
# filename: cloudtrail_log_settings.sh
# Finding: CloudTrail.4 CloudTrail log file validation should be enabled

aws cloudtrail describe-trails|grep "LogFileValidationEnabled.*false" | awk '{print $2}' | xargs -I {} aws cloudtrail update-trail --name {} --enable-log-file-validation

#Note: If all trails need log file validation enabled, just remove the grep and awk commands from the pipeline.