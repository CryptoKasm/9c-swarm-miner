#!/bin/bash
source bin/consoleStyle.sh

# Write: settings.conf
writeConfig() {
    consoleEntry "6" "4" "1" "1"
    if [ -f "settings.conf" ]; then
        echo "   --File Found: settings.conf" 
    else
        cat > settings.conf << EOF
# Nine Chronicles - CryptoKasm Swarm Miner

# Turn on/off debugging for this script (1 ON/0 OFF)
DEBUG=0

# Set log level for all miners
LOG_LEVEL=debug

# Nine Chronicles Private Key **KEEP SECRET**
NC_PRIVATE_KEY=$NCPK

# Nine Chronicles Public Key **ALLOWS QUERY FOR NCG**
NC_PUBLIC_KEY=

# Amount of Miners **DOCKER CONTAINERS**
NC_MINERS=1

# Set MAX RAM Per Miner **PROTECTION FROM MEMORY LEAKS** 
NC_RAM_LIMIT=6144M

# Set MIN RAM Per Miner **SAVES RESOURCES FOR THAT CONTAINER** 
NC_RAM_RESERVE=2048M

# Refresh Snapshot each run (NATIVE LINUX ONLY 4 NOW) (1 ON/0 OFF)
NC_REFRESH_SNAPSHOT=1

# Cronjob Auto Restart **HOURS** (0 OFF)
NC_CRONJOB_AUTO_RESTART=2

# Enable GraphQL Query Commands
NC_GRAPHQL_QUERIES=1
EOF

    fi

}

###############################
configMain() {
    #consoleTitle "Building Configuration File"
    echo -e " | Please enter the requested information or press enter and edit later!"
    echo -e " | Edit configuration file after creation:$RS settings.conf"
    echo
    read -p "$(echo -e $P">$sB SECRET_KEY: "$RS)" NCPK
    echo
    writeConfig
}
###############################
configMain