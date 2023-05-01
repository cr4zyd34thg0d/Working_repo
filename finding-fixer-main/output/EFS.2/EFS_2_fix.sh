#!/bin/bash
#backup_efs_volumes.sh
# Finding: EFS.2 Amazon EFS volumes should be in backup plans
aws efs describe-file-systems | jq -r '.FileSystems[].FileSystemId' | while read fs_id
do
  aws backup create-backup-plan --backup-plan-name "EFS Backup Plan ${fs_id}" --rules "[
    {
      \"ruleName\": \"${fs_id} daily backup\",
      \"targetBackupVaultName\": \"EFS Backup Vault\",
      \"scheduleExpression\": \"cron(0 2 * * ? *)\",
      \"startWindowMinutes\": 60,
      \"completionWindowMinutes\": 120,
      \"lifecycle\": {
        \"deleteAfterDays\": 30,
        \"moveToColdStorageAfterDays\": 7
      },
      \"copyActions\": []
    }
  ]"
done