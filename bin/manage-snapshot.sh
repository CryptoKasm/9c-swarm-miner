#!/bin/bash
source bin/cklib.sh

# Check: ROOT
checkRoot

# Check: Settings
checkSettings

# Check: Build Params
checkBuildParams

# Set: Variables
NC_SNAPDIR="latest-snapshot"
NC_SNAPSHOT="$NC_SNAPDIR/9c-main"
NC_SNAPZIP="9c-main-snapshot.zip"

# Copy: Snapshot to Volumes
copyVolume(){
    startSpinner "Copying snapshot to miners:"
    {
    docker-compose up -d        # Restarts to recreate clean environment
    docker-compose stop         # Stops cleaned environment for snapshot update
    } &> /dev/null

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
    sudo chmod -R 700 .
    mv 9c-main-snapshot.zip ../
    stopSpinner $?
    copyVolume
}

# Test: Refresh if volume is missing
testVol() {
    sL
    sTitle "Volume Management: $(checkPlatform)"
    {
    docker-compose up -d       # Restarts to recreate clean environment
    docker-compose stop
    } &> /dev/null

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
    {
    docker-compose stop         # Stops cleaned environment for snapshot update
    } &> /dev/null
}

# Test: Ignore Volume test if docker containers are running
testDockerRunning() {
    if [ ! "$(docker ps -qf "name=^9c-swarm-miner")" ]; then
        testVol
    fi
}

# Test: Refresh if older than 2 hrs
testAge() {
    sL
    sTitle "Snapshot Management: $(checkPlatform)"
    if [ -d "$NC_SNAPSHOT" ] && [ -f "$NC_SNAPZIP" ]; then
        sudo chmod -R 700 $NC_SNAPSHOT
        if [[ $(find "9c-main-snapshot.zip" -type f -mmin +60) ]]; then
            refreshSnapshot
        else
            sEntry "Snapshot is current!"
            testDockerRunning
        fi
    else
        refreshSnapshot
    fi
}

# Force refresh of snapshot
forceRefresh() {
    sL
    sTitle "Snapshot Management: $(checkPlatform)"
    refreshSnapshot
    sLL
}

###############################
snapshotMain() {
    testAge
}
###############################
case $1 in

  --force)
    forceRefresh
    exit 0
    ;;

  --volume)
    testVol
    exit 0
    ;;

  --running)
    testDockerRunning
    exit 0
    ;;

  *)
    snapshotMain
    exit 0
    ;;

esac