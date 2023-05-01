#!/bin/bash
#filename: elb_tls_termination.sh
# Finding: ELB.3 Classic Load Balancer listeners should be configured with HTTPS or TLS termination
aws elb describe-load-balancers | jq -r '.LoadBalancerDescriptions[] | .LoadBalancerName' | while read lb_name; do
    aws elb describe-listeners --load-balancer-name $lb_name| jq -r '.ListenerDescriptions[] | {listener: .Listener, lb_name: "'$lb_name'"}' | while read listener_details; do
        listener_protocol=$(echo $listener_details | jq -r '.listener.Protocol')
        if [[ $listener_protocol == "HTTP" ]]; then
            listener_port=$(echo $listener_details | jq -r '.listener.LoadBalancerPort')
            listener_instance_port=$(echo $listener_details | jq -r '.listener.InstancePort')
            instance_protocol="HTTP"
            certificate_arn=$(aws acm list-certificates --query "CertificateSummaryList[?DomainName=='$lb_name'].CertificateArn" --output text)
            if [ "$certificate_arn" != "" ]; then
                aws elb create-load-balancer-listeners --load-balancer-name $lb_name --listeners Protocol=HTTPS,LoadBalancerPort=$listener_port,InstanceProtocol=$instance_protocol,InstancePort=$listener_instance_port,SSLCertificateId=$certificate_arn
                aws elb delete-load-balancer-listeners --load-balancer-name $lb_name --load-balancer-ports $listener_port
            else
                echo "Certificate not found for $lb_name at port $listener_port"
            fi
        fi
    done
done