#!/bin/bash
# filename: eks_endpoint_security.sh
# Finding: EKS.1 EKS cluster endpoints should not be publicly accessible

aws eks update-cluster-config \
--name <cluster-name> \
--region <region> \
--resources-vpc-config endpointPublicAccess=false,endpointPrivateAccess=true