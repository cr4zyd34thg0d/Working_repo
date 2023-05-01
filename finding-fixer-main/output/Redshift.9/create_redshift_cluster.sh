#!/bin/bash
# create_redshift_cluster.sh
# Finding: Redshift.9 Redshift clusters should not use the default database name

aws redshift create-cluster --node-type dc2.large --number-of-nodes 4 --cluster-identifier my-redshift-cluster --master-username myusername --master-user-password mypassword --db-name mycustomdbname --availability-zone us-west-2a