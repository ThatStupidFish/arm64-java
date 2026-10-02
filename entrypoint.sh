#!/bin/bash

TZ=${TZ:-UTC}
export TZ

INTERNAL_IP=$(ip route get 1 2>/dev/null | awk '{print $(NF-2); exit}')
export INTERNAL_IP

cd /home/container || exit 1

printf "\033[1m\033[33mcontainer@arm64-java~ \033[0mjava -version\n"
java -version

if [ -z "${STARTUP}" ]; then
    echo "STARTUP is not set; configure a startup command in the panel." >&2
    exit 1
fi

# Panels send the startup command with {{VARIABLE}} placeholders; turn them into
# ${VARIABLE} so the shell substitutes the server's environment values.
PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')

printf "\033[1m\033[33mcontainer@arm64-java~ \033[0m%s\n" "${PARSED}"
eval "${PARSED}"
