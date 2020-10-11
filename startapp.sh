#!/bin/sh

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Starting"

if [ -f "/run/secrets/idrac_host" ]; then
    echo "Using Docker secret for IDRAC_HOST"
    IDRAC_HOST="$(cat /run/secrets/idrac_host)"
fi

if [ -f "/run/secrets/idrac_port" ]; then
    echo "Using Docker secret for IDRAC_PORT"
    IDRAC_PORT="$(cat /run/secrets/idrac_port)"
fi

if [ -f "/run/secrets/idrac_user" ]; then
    echo "Using Docker secret for IDRAC_USER"
    IDRAC_USER="$(cat /run/secrets/idrac_user)"
fi

if [ -f "/run/secrets/idrac_password" ]; then
    echo "Using Docker secret for IDRAC_PASSWORD"
    IDRAC_PASSWORD="$(cat /run/secrets/idrac_password)"
fi

if [ -f "/run/secrets/groupmgr_host" ]; then
    echo "Using Docker secret for GROUPMGR_HOST"
    GROUPMGR_HOST="$(cat /run/secrets/groupmgr_host)"
fi

if [ -z "${GROUPMGR_HOST}" ]; then
    if [ -z "${IDRAC_HOST}" ]; then
        echo "${RED}Please set a proper idrac host with IDRAC_HOST${NC}"
        sleep 2
        exit 1
    fi

    if [ -z "${IDRAC_PORT}" ]; then
        echo "${RED}Please set a proper idrac port with IDRAC_PORT${NC}"
        sleep 2
        exit 1
    fi

    if [ -z "${IDRAC_USER}" ]; then
        echo "${RED}Please set a proper idrac user with IDRAC_USER${NC}"
        sleep 2
        exit 1
    fi

    if [ -z "${IDRAC_PASSWORD}" ]; then
        echo "${RED}Please set a proper idrac password with IDRAC_PASSWORD${NC}"
        sleep 2
        exit 1
    fi

    echo "Environment ok"

    cd /app

    echo "Testing for iDRAC type"

    if curl -s -k "https://${IDRAC_HOST}:${IDRAC_PORT}/login.html" --compressed | grep -q iDRAC6
    then
            echo "${GREEN}This is an iDRAC6 server${NC}"
            IDRAC_JNLP="IDRAC6.jnlp"
    	sed -i "s/REPLACE_WITH_IP/${IDRAC_HOST}/" /templates/IDRAC6.jnlp
            sed -i "s/REPLACE_WITH_PORT/${IDRAC_PORT}/" /templates/IDRAC6.jnlp
    	sed -i "s/REPLACE_WITH_USER/${IDRAC_USER}/" /templates/IDRAC6.jnlp
    	sed -i "s/REPLACE_WITH_PASSWD/${IDRAC_PASSWORD}/" /templates/IDRAC6.jnlp
    elif curl -s -k "https://${IDRAC_HOST}:${IDRAC_PORT}/data?get=prodServerGen" | grep -q 12G; then
            echo "${GREEN}This is an iDRAC7 server${NC}"
    	IDRAC_JNLP="IDRAC789.jnlp"
    	sed -i "s/REPLACE_WITH_IP/${IDRAC_HOST}/" /templates/IDRAC789.jnlp
            sed -i "s/REPLACE_WITH_PORT/${IDRAC_PORT}/" /templates/IDRAC789.jnlp
            sed -i "s/REPLACE_WITH_USER/${IDRAC_USER}/" /templates/IDRAC789.jnlp
            sed -i "s/REPLACE_WITH_PASSWD/${IDRAC_PASSWORD}/" /templates/IDRAC789.jnlp
    elif curl -s -k "https://${IDRAC_HOST}:${IDRAC_PORT}/data?get=prodServerGen" | grep -q 13G; then
            echo "${GREEN}This is an iDRAC8 server${NC}"
    	IDRAC_JNLP="IDRAC789.jnlp"
            sed -i "s/REPLACE_WITH_IP/${IDRAC_HOST}/" /templates/IDRAC789.jnlp
            sed -i "s/REPLACE_WITH_PORT/${IDRAC_PORT}/" /templates/IDRAC789.jnlp
            sed -i "s/REPLACE_WITH_USER/${IDRAC_USER}/" /templates/IDRAC789.jnlp
            sed -i "s/REPLACE_WITH_PASSWD/${IDRAC_PASSWORD}/" /templates/IDRAC789.jnlp
    elif curl -s -k "https://${IDRAC_HOST}:${IDRAC_PORT}/sysmgmt/2015/bmc/info" | grep -q "14G"; then
            echo "${GREEN}This is an iDRAC9 server${NC}"
    	IDRAC_JNLP="IDRAC789.jnlp"
            sed -i "s/REPLACE_WITH_IP/${IDRAC_HOST}/" /templates/IDRAC789.jnlp
            sed -i "s/REPLACE_WITH_PORT/${IDRAC_PORT}/" /templates/IDRAC789.jnlp
            sed -i "s/REPLACE_WITH_USER/${IDRAC_USER}/" /templates/IDRAC789.jnlp
            sed -i "s/REPLACE_WITH_PASSWD/${IDRAC_PASSWORD}/" /templates/IDRAC789.jnlp
    else
    	echo "${RED}Unknown iDRAC type... this container only supports iDRAC 6-8${NC}"
    	exit 1
    fi

    echo "${GREEN}Initialization complete, starting virtual console${NC}"

    if [ -n "$IDRAC_KEYCODE_HACK" ]; then
        echo "Enabling keycode hack"

        export LD_PRELOAD=/keycode-hack.so
    fi

    exec javaws /templates/${IDRAC_JNLP}
else
   sed -i "s/REPLACE_WITH_IP/${GROUPMGR_HOST}/" /templates/GROUPMGR.jnlp
   exec javaws /templates/GROUPMGR.jnlp
fi
