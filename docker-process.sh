#!/bin/bash

set -e

echo -n "Waiting config file /etc/keepalived/keepalived.conf"
while [ ! -e "/etc/keepalived/keepalived.conf" ]
do
  echo -n "."
  sleep 0.1
done
echo "ok"

exec /usr/local/sbin/keepalived -f /etc/keepalived/keepalived.conf --dont-fork --log-console ${KEEPALIVED_COMMAND_LINE_ARGUMENTS}
