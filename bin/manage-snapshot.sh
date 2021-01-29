#!/bin/bash
source bin/consoleStyle.sh

# Test: Root Privileges
if [ "$EUID" -ne 0 ]; then
    sudo echo ""
fi

NC_SNAPDIR="latest-snapshot"
NC_SNAPSHOT="$NC_SNAPDIR/9c-main"
NC_SNAPZIP="9c-main-snapshot.zip"

# Check: Platform (Native Linux or WSL)
checkPlatform() {
    if grep -q icrosoft /proc/version; then
        PLATFORM="WSL"
    else
        PLATFORM="NATIVE"
    fi
    echo $PLATFORM
}

# Check: Settings.conf
checkConfig() {
    if [ -f "settings.conf" ]; then
        source settings.conf
    else
        echo -e $P">$sB Please run setup! Then re-run this script"$RS
        exit 1
    fi
}

# Check: buildparams.txt
checkBuildParams() {
    if [ -f "buildparams.txt" ]; then
        source buildparams.txt
    else
        echo -e $P">$sB Please run setup! Then re-run this script"$RS
        exit 1
    fi
}

# Copy: Snapshot to Volumes
copyVolume(){
    consoleTitle "Preparing Volumes on Platform"
    
    for ((i=1; i<=$NC_MINERS; i++)); do
        echo -ne $S"|$RS Miner$((i))_1       $S|$C Copying...     $S|$C $(prog "1")\r"
        # NOTE: The location and the name of the docker volumes may differ, depending on the system.
        sudo docker cp . 9c-swarm-miner_swarm-miner$((i))_1:/app/data/
        echo -e $S"|$RS Miner$((i))_1       $S|$C Ready          $S|$C $(prog "10")"
    done
}

# Refresh: Snapshot
refreshSnapshot() {
    consoleTitle "Refreshing Snapshot"

    consoleEntry "8" "11" "1" "1"
    {
    docker-compose down -v --remove-orphans     # Stops & deletes environment **snapshot**
    docker-compose up -d        # Restarts to recreate clean environment
    docker-compose stop         # Stops cleaned environment for snapshot update
    } &> /dev/null
    consoleEntry "8" "12" "10" "0"
    
    if [ -d "$NC_SNAPSHOT" ]; then
        consoleEntry "9" "11" "1" "1"
        rm -f $NC_SNAPZIP
        rm -rf latest-snapshot/* &> /dev/null
        consoleEntry "9" "12" "10" "0"
    else
        mkdir -p latest-snapshot &> /dev/null
    fi

    consoleEntry "10" "5" "1" "1"
    cd latest-snapshot
    consoleEntry "10" "5" "3" "1"
    curl -O $SNAPSHOT
    consoleEntry "10" "14" "5" "3"
    unzip 9c-main-snapshot.zip &> /dev/null
    consoleEntry "10" "15" "8" "1"
    mv 9c-main-snapshot.zip ../
    consoleEntry "10" "16" "10" "0"
    copyVolume
}

# Test: Refresh if older than 2 hrs
testAge() {
    if [ -d "$NC_SNAPSHOT" ] && [ -f "$NC_SNAPZIP" ]; then
        sudo chmod -R 700 $NC_SNAPSHOT
        if [[ $(find "9c-main-snapshot.zip" -type f -mmin +120) ]]; then
            refreshSnapshot
        else
            consoleEntry "9" "13" "0" "0"
        fi
    else
        refreshSnapshot
    fi
}

forceRefresh() {
    echo -e $P"-----------------------------------------------"$RS
    consoleTitle "Snapshot Management: $(checkPlatform)"
    checkConfig
    checkBuildParams
    refreshSnapshot
    echo
    echo -e $P"-----------------------------------------------"$RS
}

###############################
snapshotMain() {
    consoleTitle "Snapshot Management: $(checkPlatform)"
    checkConfig
    checkBuildParams
    testAge
}
###############################
if [ "$1" == "--force" ]; then
    forceRefresh
    exit 0
else
    snapshotMain
    exit 0
fi