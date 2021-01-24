#!/bin/bash

# Check: settings.conf
checkConfig() {
    echo "> Checking for Configuration File"
    if [ -f "settings.conf" ]; then
        echo "   --File Found: settings.conf" 
    else
        echo "   --Creating Configuration File: settings.conf"
        echo "    **EDIT THIS FILE TO CONFIGURE YOUR SWARM**"
        cat > settings.conf << EOF
# Nine Chronicles - CryptoKasm Swarm Miner

# Turn on/off debugging for this script (1/0)
DEBUG=0

# Set log level for all miners
LOG_LEVEL=debug

# Nine Chronicles Private Key **KEEP SECRET**
NC_PRIVATE_KEY=

# Nine Chronicles Public Key **ALLOWS QUERY FOR NCG**
NC_PUBLIC_KEY=

# Amount of Miners **DOCKER CONTAINERS**
NC_MINERS=1

# Set MAX RAM Per Miner **PROTECTION FROM MEMORY LEAKS** 
NC_RAM_LIMIT=6144M

# Set MIN RAM Per Miner **SAVES RESOURCES FOR THAT CONTAINER** 
NC_RAM_RESERVE=2048M
EOF

    fi
}

#############################################
# Main

if [ "$1" == "--MakeConfig" ]; then
    checkConfig
    exit 0
fi

#
#############################################