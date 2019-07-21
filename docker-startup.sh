#!/bin/bash

set -e

CONTAINER_DIR=/container
CONTAINER_RUN_DIR=${CONTAINER_DIR}/run
CONTAINER_TMP_DIR=${CONTAINER_DIR}/tmp
FIRST_START_DONE="${CONTAINER_RUN_DIR}/docker-first-start-done"
# container first start
if [ ! -e "$FIRST_START_DONE" ]; then
    echo "The container first start."
    # check and set default values
    if [ -z "${KEEPALIVED_INTERFACE}" ]; then
        KEEPALIVED_INTERFACE="ens33"
    fi
    if [ -z "${KEEPALIVED_STATE}" ]; then
        KEEPALIVED_STATE="MASTER"
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
        KEEPALIVED_NOTIFY="/container/service/notify.sh"
    fi
    # peers
    peers_tmp=${KEEPALIVED_UNICAST_PEERS//,/ };
    peers_arr=($peers_tmp);
    peers_len=${#peers_arr[@]}
    # peers's length < 1
    if [ ${peers_len} -lt 1 ]; then
        echo "The length of KEEPALIVED_UNICAST_PEERS must be greater than or equal to 1, and separated by commas. eg:192.168.1.11,192.168.1.12"
        exit 1
    fi
    # vips
    vips_tmp=${KEEPALIVED_VIRTUAL_IPS//,/ };
    vips_arr=($vips_tmp);
    vips_len=${#vips_arr[@]}
    # vips's length < 1
    if [ ${vips_len} -lt 1 ]; then
        echo "The length of KEEPALIVED_VIRTUAL_IPS must be greater than or equal to 1, and separated by commas. eg:192.168.1.11,192.168.1.12"
        exit 1
    fi

    mkdir -p ${CONTAINER_RUN_DIR}
    mkdir -p ${CONTAINER_TMP_DIR}

    # generate ${CONTAINER_TMP_DIR}/keepalived.json
    touch ${CONTAINER_TMP_DIR}/keepalived.json
    printf ""                                                          > ${CONTAINER_TMP_DIR}/keepalived.json
    printf "{\n"                                                       >> ${CONTAINER_TMP_DIR}/keepalived.json
    printf "\t\"keepalivedInterface\": \"${KEEPALIVED_INTERFACE}\",\n" >> ${CONTAINER_TMP_DIR}/keepalived.json
    printf "\t\"keepalivedScriptUser\": \"keepalived\",\n"             >> ${CONTAINER_TMP_DIR}/keepalived.json
    printf "\t\"keepalivedScriptGroup\": \"keepalived\",\n"            >> ${CONTAINER_TMP_DIR}/keepalived.json
    printf "\t\"keepalivedState\": \"${KEEPALIVED_STATE}\",\n"         >> ${CONTAINER_TMP_DIR}/keepalived.json
    printf "\t\"keepalivedRouterId\": ${KEEPALIVED_ROUTER_ID},\n"      >> ${CONTAINER_TMP_DIR}/keepalived.json
    printf "\t\"keepalivedPriority\": ${KEEPALIVED_PRIORITY},\n"       >> ${CONTAINER_TMP_DIR}/keepalived.json
    printf "\t\"keepalivedUnicastPeers\": [\n"                         >> ${CONTAINER_TMP_DIR}/keepalived.json
    for ((i=0;i<${#peers_arr[@]};i++)); do
        num=$(echo $((${#peers_arr[@]}-1)))
        if [ "$i" == ${num} ]; then
                printf "\t\t\"${peers_arr[$i]}\"\n"                    >> ${CONTAINER_TMP_DIR}/keepalived.json
        else
                printf "\t\t\"${peers_arr[$i]}\",\n"                   >> ${CONTAINER_TMP_DIR}/keepalived.json
        fi
    done
    printf "\t],\n"                                                    >> ${CONTAINER_TMP_DIR}/keepalived.json
    printf "\t\"keepalivedVirtualIps\": [\n"                           >> ${CONTAINER_TMP_DIR}/keepalived.json
    for ((i=0;i<${#vips_arr[@]};i++)); do
        num=$(echo $((${#vips_arr[@]}-1)))
        if [ "$i" == ${num} ]; then
                printf "\t\t\"${vips_arr[$i]}\"\n"                     >> ${CONTAINER_TMP_DIR}/keepalived.json
        else
                printf "\t\t\"${vips_arr[$i]}\",\n"                    >> ${CONTAINER_TMP_DIR}/keepalived.json
        fi
    done
    printf "\t],\n"                                                    >> ${CONTAINER_TMP_DIR}/keepalived.json
    if [ -n "${KEEPALIVED_NOTIFY}" ]; then
        printf "\t\"keepalivedNotify\": \"notify ${KEEPALIVED_NOTIFY}\",\n"   >> ${CONTAINER_TMP_DIR}/keepalived.json
        chmod +x ${KEEPALIVED_NOTIFY}
    else
        printf "\t\"keepalivedNotify\": \"\",\n"                       >> ${CONTAINER_TMP_DIR}/keepalived.json
    fi
    printf "\t\"keepalivedPassword\": \"${KEEPALIVED_PASSWORD}\"\n"    >> ${CONTAINER_TMP_DIR}/keepalived.json
    printf "}\n"                                                       >> ${CONTAINER_TMP_DIR}/keepalived.json

    echo "generate keepalived.json file success."
    cat ${CONTAINER_TMP_DIR}/keepalived.json
    echo ""

    # generate /etc/keepalived/keepalived.conf
    gotmpl --template="f:/etc/keepalived/keepalived.tmpl" --jsondata="f:${CONTAINER_TMP_DIR}/keepalived.json" --outfile="/etc/keepalived/keepalived.conf"
    echo "generate keepalived.conf file success."
    cat /etc/keepalived/keepalived.conf
    echo ""

    # important
    chmod 644 /etc/keepalived/keepalived.conf

    touch $FIRST_START_DONE
fi

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

exit 0
