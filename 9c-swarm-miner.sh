#!/bin/bash

if [ -f "settings.conf" ]; then
    source settings.conf
else
    echo "No configuration file..."
fi

echo "--------------------------------------------"
echo "  Nine Chronicles - CryptoKasm Swarm Miner"
echo "  Version: 1.3.1-alpha"
echo "--------------------------------------------"

if [ "$1" == "--Update" ]; then
    ./bin/docker-compose.sh --Update
    exit 0
else
    # Check: Platform (Native Linux or WSL)
    checkPlatform() {
        if grep -q icrosoft /proc/version; then
            echo "> "
            PLATFORM="WSL"
        else
            echo ">"
            PLATFORM="NATIVE"
        fi
    }

    # Build: Settings.conf
    ./bin/build_config.sh --MakeConfig

    # Check: Prereqs
    sudo ./bin/system.sh --Setup

    # Check: docker-compose.yml
    ./bin/docker-compose.sh --MakeCompose

    # Check: Snapshot
    #./bin/snapshot.sh --MakeSnapshot

fi

#############################################
# Main



#
#############################################