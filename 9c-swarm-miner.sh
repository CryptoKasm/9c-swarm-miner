#!/bin/bash

if [ -f "settings.conf" ]; then
    source settings.conf
else
    echo ">No configuration file..."
    echo ">Defaulting to Setup"
    FIRSTRUN=1
fi

echo "--------------------------------------------"
echo "  Nine Chronicles - CryptoKasm Swarm Miner"
echo "  Version: 1.3.1-alpha"
echo "--------------------------------------------"

if [ "$1" == "--update" ]; then
    ./bin/docker-compose.sh --Update
    exit 0
elif [ "$1" == "--setup" ] || [ "$FIRSTRUN" == "1" ]; then
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

    echo "> RUN SCRIPT AGAIN"
elif [ "$1" == "--refresh" ]; then
    ./bin/snapshot.sh --RefreshSnapshot
elif [ "$1" == "--help" ]; then
    echo "> Usage: 9c-swarm-miner.sh [OPTION]"
    echo "    --setup       Setup your system to use this script"
    echo "    --update      Update docker-compose.yml"
    echo "    --refresh     Refresh snapshot (NATIVE LINUX ONLY)"
else
    if [ $NC_REFRESH_SNAPSHOT == "1" ]; then
        ./bin/snapshot.sh --RefreshSnapshot
    fi

    echo "> Starting Docker Stack..."
    echo "  Please edit settings.conf before running the dockers"
    echo "> Run this command for options: "
    echo "     ./9c-swarm-miner.sh --help "

    if [ -z "$NC_PRIVATE_KEY" ]; then
        echo
        echo "> You must set your PRIVATE_KEY before autorun is enabled!"
        echo "  Quick Command:  $ nano settings.conf" 
        echo
        echo "> RUN SCRIPT AGAIN"
    else
        echo
        echo "----------"
        if [ -f "docker-compose.yml" ]; then
            docker-compose up -d 
        else
            echo "   --Run command before docker can run:"
            echo "                   ./9c-swarm-miner.sh --setup "
        fi
        echo "----------"
        echo
        echo "  Windows Monitor (Full Log): Goto Docker and you can access logging for each individual container."
        echo "  Windows Monitor (Mined Blocks Only): Search for Mined a block."
        echo
        echo "  Linux Monitor (Full Log): "
        echo "     docker-compose logs --tail=100 -f"
        echo "  Linux Monitor (Mined Blocks Only): "
        echo "     docker-compose logs --tail=100 -f | grep -A 10 --color -i 'Mined a block'"
        echo "  Linux Monitor (Mined/Reorg/Append failed events): "
        echo "     docker-compose logs --tail=1 -f | grep --color -i -E 'Mined a|reorged|Append failed'"
        echo
    fi
fi

#############################################
# Main



#
#############################################