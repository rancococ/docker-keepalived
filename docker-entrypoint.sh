#!/bin/bash

set -e

# exec docker-startup.sh
if [ -x "/docker-startup.sh" ]; then
    . "/docker-startup.sh"
fi

# exec docker-process.sh
if [ -x "/docker-process.sh" ]; then
    . "/docker-process.sh"
fi

# exec docker-finish.sh
if [ -x "/docker-finish.sh" ]; then
    . "/docker-finish.sh"
fi

# exec some command
# exec "$@"
