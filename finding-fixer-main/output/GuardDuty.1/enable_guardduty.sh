#!/bin/bash
#filename: enable_guardduty.sh
# Finding: GuardDuty.1 GuardDuty should be enabled
aws guardduty list-detectors # check if GuardDuty is already enabled
aws guardduty create-detector --enable # if not enabled, enable GuardDuty 
aws guardduty list-detectors # check if GuardDuty is enabled now