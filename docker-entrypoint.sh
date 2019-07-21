#!/bin/bash

set -e

# exec docker-startup.sh
if [ -x "/docker-startup.sh" ]; then
  bash "/docker-startup.sh"
fi


# exec docker-process.sh
if [ -x "/docker-process.sh" ]; then
  bash "/docker-process.sh"
fi

# exec docker-finish.sh
if [ -x "/docker-finish.sh" ]; then
  bash "/docker-finish.sh"
fi

# exec some command
exec "$@"
