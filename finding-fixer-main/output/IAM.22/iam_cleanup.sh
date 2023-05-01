#!/bin/bash
#filename: iam_cleanup.sh
# Finding: IAM.22 IAM user credentials unused for 45 days should be removed

aws iam list-users | grep UserName | awk '{print $2}' | tr -d '",' | while read user; do
    last_activity=$(aws iam get-user --user-name $user | grep PasswordLastUsed | awk '{print $2}' | tr -d '",')
    if [[ $last_activity != "null" ]]; then
        last_activity_seconds=$(date +%s -d $last_activity)
        current_time_seconds=$(date +%s)
        if (( ($current_time_seconds - $last_activity_seconds) > (45 * 24 * 60 * 60) )); then
            aws iam delete-user --user-name $user
        fi
    fi
done