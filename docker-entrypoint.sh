#!/bin/bash

set -e

# exec keepalived-setup.sh
if [ -x "/keepalived-setup.sh" ]; then
    . "/keepalived-setup.sh"
fi

# exec keepalived-clean.sh
if [ -x "/keepalived-clean.sh" ]; then
    . "/keepalived-clean.sh"
fi

# current user is root
if [ "$(id -u)" = "0" ]; then
    #echo -n "waiting config file /etc/keepalived/keepalived.conf"
    #while [ ! -e "/etc/keepalived/keepalived.conf" ]
    #do
    #    echo -n "."
    #    sleep 0.1
    #done
    #echo "ok"
    # start keepalived
    exec /usr/local/sbin/keepalived -f /etc/keepalived/keepalived-new.conf --dont-fork --log-console ${KEEPALIVED_COMMAND_LINE_ARGUMENTS}
fi

# exec some command
exec "$@"
