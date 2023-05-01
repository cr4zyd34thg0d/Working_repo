#!/bin/bash
# remove_public_ips.sh
# Finding: EMR.1 Amazon Elastic MapReduce cluster master nodes should not have public IP addresses
aws emr list-clusters | jq -r '.Clusters[].Id' |
while read cluster
do
    aws emr describe-cluster --cluster-id $cluster |
    jq -r '.Cluster.MasterPublicDnsName' |
    while read dns
    do
        aws ec2 describe-instances --filters "Name=private-dns-name,Values="$dns"" |
        jq -r '.Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp' |
        while read ip
        do
            aws ec2 disassociate-address --public-ip $ip
            aws ec2 release-address --public-ip $ip
        done
    done
done