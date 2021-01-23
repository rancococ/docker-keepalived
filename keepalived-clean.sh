#!/bin/bash

set -e

echo "run the script keepalived-clean.sh"

# try to delete virtual ips from interface
vips_tmp=${KEEPALIVED_VIRTUAL_IPS//,/ };
vips_arr=($vips_tmp);
for vip in ${vips_arr[@]}; do
    IP=$(echo ${vip})
    IP_INFO=$(ip addr list | grep ${IP}) || continue
    IP_V6=$(echo "${IP_INFO}" | grep "inet6") || true

    # ipv4
    if [ -z "${IP_V6}" ]; then
        IP_INTERFACE=$(echo "${IP_INFO}" |  awk '{print $5}')
    # ipv6
    else
        echo "skipping address: ${IP} - ipv6 not supported yet :("
        continue
    fi

    ip addr del ${IP} dev ${IP_INTERFACE} || true
done

# try to delete keepalived.pid and vrrp.pid
rm -rf /var/run/keepalived.pid
rm -rf /var/run/vrrp.pid
