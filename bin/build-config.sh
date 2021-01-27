#!/bin/bash

Y="\e[93m"
M="\e[95m"
C="\e[96m"
G="\e[92m"
Re="\e[91m"
R="\e[0m"
RL="\e[1A\e["

# Exit with reason
error_exit()
{
  echo "$1" 1>&2
  exit 1
}

# Write: settings.conf
writeConfig() {
    echo -e "$C   -Creating file:$R$G settings.conf$R"
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
NC_REFRESH_SNAPSHOT=0
EOF

    fi
}

###############################
configMain() {
    echo -e "$M>Building Configuration File$R"
    echo -e "$C   -Please enter the requested information or press enter and edit later!$R"
    echo -e "$C   -Edit configuration file after creation:$R$G settings.conf$R"
    echo
    read -p "$(echo -e $Y">SECRET_KEY: "$R)" NCPK
    echo
    writeConfig
}
###############################
configMain