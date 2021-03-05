#!/bin/bash
source bin/cklib.sh

# Check: ROOT
cRoot

# Check: Settings
cSettings

# Check: Build Params
cBuildParams

# Set: Variables
NC_SNAPDIR="latest-snapshot"
NC_SNAPSHOT="$NC_SNAPDIR/9c-main"
NC_SNAPZIP="9c-main-snapshot.zip"

# Copy: Snapshot to Volumes
copyVolume(){
    startSpinner "Copying snapshot to miners:"
    for ((i=1; i<=$NC_MINERS; i++)); do
        # NOTE: The location and the name of the docker volumes may differ, depending on the system.
        {
            sudo docker cp . 9c-swarm-miner_swarm-miner$((i))_1:/app/data/
        } &> /dev/null
    done
    stopSpinner $?
}

# Refresh: Snapshot
refreshSnapshot() {
    startSpinner "Refreshing snapshot:"

    {
    docker-compose down -v    # Stops & deletes environment **snapshot**
    docker-compose up -d        # Restarts to recreate clean environment
    docker-compose stop         # Stops cleaned environment for snapshot update
    } &> /dev/null
    
    if [ -d "$NC_SNAPSHOT" ]; then
        rm -rf latest-snapshot/* &> /dev/null
        
        if [ -f $NC_SNAPZIP ]; then 
            rm -f $NC_SNAPZIP &> /dev/null 
        fi
    else
        mkdir -p latest-snapshot &> /dev/null
    fi

    cd latest-snapshot
    curl -# -O $SNAPSHOT &> /dev/null
    unzip 9c-main-snapshot.zip &> /dev/null
    mv 9c-main-snapshot.zip ../
    stopSpinner $?
    copyVolume
}

# Test: Refresh if volume is missing
testVol() {
    for OUTPUT in $(docker ps -aqf "name=^9c-swarm-miner" --no-trunc)
        do
        Dname=$(docker ps -af "id=$OUTPUT" --format {{.Names}})
        VolChecker=$(docker exec $OUTPUT [ -d "/app/data/9c-main" ])
        VolCheckerID=$?
        if [[ $VolCheckerID = "1" ]]; then
            sEntry "$Dname Snapshot Volumes are missing!"
            cd latest-snapshot
            copyVolume
                else
            sEntry "$Dname Snapshot Volumes are current!"
        fi
        done
}

# Test: Refresh if older than 2 hrs
testAge() {
    if [ -d "$NC_SNAPSHOT" ] && [ -f "$NC_SNAPZIP" ]; then
        sudo chmod -R 700 $NC_SNAPSHOT
        if [[ $(find "9c-main-snapshot.zip" -type f -mmin +60) ]]; then
            refreshSnapshot
        else
            sEntry "Snapshot is current!"
        fi
    else
        refreshSnapshot
    fi
}

forceRefresh() {
    sLL
    sTitle "Snapshot Management: $(cPlatform)"
    refreshSnapshot
    sLL
}

###############################
snapshotMain() {
    sLL
    sTitle "Snapshot Management: $(cPlatform)"
    testAge
    testVol
}
###############################
if [ "$1" == "--force" ]; then
    forceRefresh
    exit 0
else
    snapshotMain
    exit 0
fi