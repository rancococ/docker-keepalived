#!/bin/bash

set -e

KEEPALIVED_JSON="/etc/keepalived/keepalived.json"
KEEPALIVED_CONF="/etc/keepalived/keepalived.conf"

# automatically generated when keepalived.conf does not exist
if [ ! -e "${KEEPALIVED_CONF}" ]; then
    echo "the container first start."
    # check and set default values
    if [ -z "${KEEPALIVED_INTERFACE}" ]; then
        KEEPALIVED_INTERFACE="ens33"
    fi
    if [ -z "${KEEPALIVED_STATE}" ]; then
        KEEPALIVED_STATE="BACKUP"
    fi
    if [ -z "${KEEPALIVED_ROUTER_ID}" ]; then
        KEEPALIVED_ROUTER_ID="100"
    fi
    if [ -z "${KEEPALIVED_PRIORITY}" ]; then
        KEEPALIVED_PRIORITY="51"
    fi
    if [ -z "${KEEPALIVED_PASSWORD}" ]; then
        KEEPALIVED_PASSWORD="abcd1234"
    fi
    if [ -z "${KEEPALIVED_NOTIFY}" ]; then
        KEEPALIVED_NOTIFY="/keepalived-notify.sh"
    fi
    # peers
    peers_tmp=${KEEPALIVED_UNICAST_PEERS//,/ };
    peers_arr=($peers_tmp);
    peers_len=${#peers_arr[@]}
    # peers's length < 1
    if [ ${peers_len} -lt 1 ]; then
        echo "the length of KEEPALIVED_UNICAST_PEERS must be greater than or equal to 1, and separated by commas. eg:192.168.1.11,192.168.1.12"
        exit 1
    fi
    # vips
    vips_tmp=${KEEPALIVED_VIRTUAL_IPS//,/ };
    vips_arr=($vips_tmp);
    vips_len=${#vips_arr[@]}
    # vips's length < 1
    if [ ${vips_len} -lt 1 ]; then
        echo "the length of KEEPALIVED_VIRTUAL_IPS must be greater than or equal to 1, and separated by commas. eg:192.168.1.11,192.168.1.12"
        exit 1
    fi

    # generate ${KEEPALIVED_JSON}
    mkdir -p /tmp
    touch ${KEEPALIVED_JSON}
    printf ""                                                                                     > ${KEEPALIVED_JSON}
    printf "{\n"                                                                                 >> ${KEEPALIVED_JSON}
    printf "\t\"keepalivedInterface\": \"${KEEPALIVED_INTERFACE}\",\n"                           >> ${KEEPALIVED_JSON}
    printf "\t\"keepalivedState\": \"${KEEPALIVED_STATE}\",\n"                                   >> ${KEEPALIVED_JSON}
    printf "\t\"keepalivedRouterId\": ${KEEPALIVED_ROUTER_ID},\n"                                >> ${KEEPALIVED_JSON}
    printf "\t\"keepalivedPriority\": ${KEEPALIVED_PRIORITY},\n"                                 >> ${KEEPALIVED_JSON}
    printf "\t\"keepalivedUnicastSrcIp\": \"${KEEPALIVED_UNICAST_SRC_IP}\",\n"                   >> ${KEEPALIVED_JSON}
    printf "\t\"keepalivedUnicastPeers\": [\n"                                                   >> ${KEEPALIVED_JSON}
    for ((i=0;i<${#peers_arr[@]};i++)); do
        num=$(echo $((${#peers_arr[@]}-1)))
        if [ "$i" == ${num} ]; then
                printf "\t\t\"${peers_arr[$i]}\"\n"                                              >> ${KEEPALIVED_JSON}
        else
                printf "\t\t\"${peers_arr[$i]}\",\n"                                             >> ${KEEPALIVED_JSON}
        fi
    done
    printf "\t],\n"                                                                              >> ${KEEPALIVED_JSON}
    printf "\t\"keepalivedVirtualIps\": [\n"                                                     >> ${KEEPALIVED_JSON}
    for ((i=0;i<${#vips_arr[@]};i++)); do
        num=$(echo $((${#vips_arr[@]}-1)))
        if [ "$i" == ${num} ]; then
                printf "\t\t\"${vips_arr[$i]} dev ${KEEPALIVED_INTERFACE} label ${KEEPALIVED_INTERFACE}:vip\"\n"          >> ${KEEPALIVED_JSON}
        else
                printf "\t\t\"${vips_arr[$i]} dev ${KEEPALIVED_INTERFACE} label ${KEEPALIVED_INTERFACE}:vip\",\n"         >> ${KEEPALIVED_JSON}
        fi
    done
    printf "\t],\n"                                                                              >> ${KEEPALIVED_JSON}
    if [ -n "${KEEPALIVED_NOTIFY}" ]; then
        printf "\t\"keepalivedNotify\": \"notify ${KEEPALIVED_NOTIFY}\",\n"                      >> ${KEEPALIVED_JSON}
        chmod +x ${KEEPALIVED_NOTIFY}
    else
        printf "\t\"keepalivedNotify\": \"\",\n"                                                 >> ${KEEPALIVED_JSON}
    fi
    printf "\t\"keepalivedPassword\": \"${KEEPALIVED_PASSWORD}\"\n"                              >> ${KEEPALIVED_JSON}
    printf "}\n"                                                                                 >> ${KEEPALIVED_JSON}

    echo "generate ${KEEPALIVED_JSON} success."
    cat ${KEEPALIVED_JSON}
    echo ""

    # generate ${KEEPALIVED_CONF}
    gotmpl --template="f:/etc/keepalived/keepalived.tmpl" --jsondata="f:${KEEPALIVED_JSON}" --outfile="${KEEPALIVED_CONF}"
    # important
    chmod 644 ${KEEPALIVED_CONF}
    echo "generate ${KEEPALIVED_CONF} success."
    cat ${KEEPALIVED_CONF}
    echo "remove temp file"
    \rm -rf /etc/keepalived/keepalived.tmpl
    \rm -rf ${KEEPALIVED_JSON}
    echo ""
fi
