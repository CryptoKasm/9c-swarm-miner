#!/bin/bash

# Refresh: Snapshot
checkSnapshot() {
    echo "> Refreshing Snapshot"
    echo "   --Cleaning docker environment..."

    docker-compose down -v --remove-orphans     # Stops & deletes environment **snapshot**
    docker-compose up -d        # Restarts to recreate clean environment
    docker-compose stop         # Stops cleaned environment for snapshot update
    
    echo "   --Checking for old snapshot..."
    NC_SNAPSHOT=latest-snapshot/9c-main
    if [ -d "$NC_SNAPSHOT" ]; then
        echo "      -Snapshot found."
        echo "      -Deleting..."
        rm -rf latest-snapshot/*
    else
        echo "      -Snapshot not found."
        mkdir -p latest-snapshot
    fi

    echo "   --Downloading new snapshot..."
    cd latest-snapshot
    curl -O https://download.nine-chronicles.com/latest/9c-main-snapshot.zip
    echo "      -Unzipping snapshot"
    unzip 9c-main-snapshot.zip
    echo "      -Removing tmp files"
    rm 9c-main-snapshot.zip
    
    echo " -> Preparing volumes..."
    
    if [ $PLATFORM = "WSL" ]; then
        echo "Ubuntu on Windows"
        # Windows Explorer Location: \\wsl$\docker-desktop-data\version-pack-data\community\docker\volumes
        # Access on Linux Side: Following https://github.com/microsoft/WSL/discussions/4176
        # VOLUMES=/var/lib/docker/volumes/9c-swarm-miner_swarm-miner$((i))-volume/_data/
    else
        echo " Native Linux"
        VOLUMES=/var/lib/docker/volumes/9c-swarm-miner_swarm-miner$((i))-volume/_data/
    fi

    for ((i=1; i<=$NC_MINERS; i++)); do
        echo "   --Copying to swarm-miner$i-volume..."
        # NOTE: The location and the name of the docker volumes may differ, depending on the system.
        sudo cp -r ./* $VOLUMES
    done
    echo "   --Volumes have been updated with newest snapshot."
}

if [ "$1" == "--RefreshSnapshot" ]; then
    checkSnapshot
    exit 0
fi