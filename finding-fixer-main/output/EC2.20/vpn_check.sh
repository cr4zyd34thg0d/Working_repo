#!/bin/bash
# filename: vpn_check.sh
# Finding: EC2.20 Both VPN tunnels for an AWS Site-to-Site VPN connection should be up

aws ec2 describe-vpn-connections --filters Name=vpn-gateway-id,Values=[VGATEWAY-ID] | grep 'State:' | sort -u | sed 's/State:[[:space:]]*//g' > /tmp/vpn_state

if [ $(cat /tmp/vpn_state | wc -l) -eq 1 ]
then
    if [ $(cat /tmp/vpn_state) == 'available' ]
    then
        echo "Both VPN tunnels are already up."
        exit 0
    fi
else
    echo "VPN tunnels are down. Bringing them up..."
    aws ec2 modify-vpn-connection --vpn-connection-id [VPN-CONN-1-ID] --options "StaticRoutesOnly=true"
    aws ec2 modify-vpn-connection --vpn-connection-id [VPN-CONN-2-ID] --options "StaticRoutesOnly=true"
    echo "VPN tunnels are now up."
fi

exit 0