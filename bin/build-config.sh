#!/bin/bash
source bin/cklib.sh

# Default Options
defaultOptions() {
    NC_1='0'
    NC_2='debug'
    NC_3="$NCPK"
    NC_4="$NCPLK"
    NC_5='1'
    NC_6='6144M'
    NC_7='2048M'
    NC_8='1'
    NC_9='0'
    NC_10='1'
    NC_11='1'
}

# Write: settings.conf
writeConfig() {
    if [ -f "settings.conf" ]; then
        echo "   --File Found: settings.conf" 
    else
        cat > settings.conf << EOF
# Nine Chronicles - CryptoKasm Swarm Miner

# Turn on/off debugging for this script (1 ON/0 OFF)
DEBUG=$NC_1

# Set log level for all miners
LOG_LEVEL=$NC_2

# Nine Chronicles Private Key **KEEP SECRET**
NC_PRIVATE_KEY=$NC_3

# Nine Chronicles Public Key **ALLOWS QUERY FOR NCG**
NC_PUBLIC_KEY=$NC_4

# Amount of Miners **DOCKER CONTAINERS**
NC_MINERS=$NC_5

# Set MAX RAM Per Miner **PROTECTION FROM MEMORY LEAKS** 
NC_RAM_LIMIT=$NC_6

# Set MIN RAM Per Miner **SAVES RESOURCES FOR THAT CONTAINER** 
NC_RAM_RESERVE=$NC_7

# Refresh Snapshot each run (NATIVE LINUX ONLY 4 NOW) (1 ON/0 OFF)
NC_REFRESH_SNAPSHOT=$NC_8

# Cronjob Auto Restart **HOURS** (0 OFF)
NC_CRONJOB_AUTO_RESTART=$NC_9

# Enable GraphQL Query Commands
NC_GRAPHQL_QUERIES=$NC_10

#Enable Emailing to Support Team (0 OFF)
NC_EMAIL=$NC_11
EOF

    fi

}

# Create new config with previous variables
rebuildConfig() {
    if [ -f ".bak.settings.conf" ]; then
        rm -f settings.conf

        source .bak.settings.conf
        NC_1="$DEBUG"
        NC_2="$LOG_LEVEL"
        NC_3="$NC_PRIVATE_KEY"
        NC_4="$NC_PUBLIC_KEY"
        NC_5="$NC_MINERS"
        NC_6="$NC_RAM_LIMIT"
        NC_7="$NC_RAM_RESERVE"
        NC_8="$NC_REFRESH_SNAPSHOT"
        NC_9="$NC_CRONJOB_AUTO_RESTART"
        NC_10="$NC_GRAPHQL_QUERIES"
        NC_11="$NC_EMAIL"

        writeConfig

        rm -f .bak.settings.conf
    else
        errCode "settings.conf backup not found."
    fi
}

# Backup & Update Config File
updateConfig() {
    sL
    startSpinner "Rebuilding settings.conf:"
    mv settings.conf .bak.settings.conf
    rebuildConfig
    stopSpinner $?
}

###############################
configMain() {
    sL
    sTitle "Building settings.conf"
    sAction "Please enter the requested information or press enter and edit later!"
    sAction "Edit configuration file after creation: settings.conf"
    sSpacer
    read -p "$(echo -e $P"|$sB PUBLIC_KEY: "$RS)" NCPLK
    sSpacer
    sSpacer
    read -p "$(echo -e $P"|$sB SECRET_KEY: "$RS)" NCPK
    sSpacer
    startSpinner "Writing settings.conf:"
    defaultOptions
    writeConfig
    stopSpinner $?
}
###############################
case $1 in

  --update)
    updateConfig
    exit 0
    ;;

  *)
    configMain
    exit 0
    ;;

esac