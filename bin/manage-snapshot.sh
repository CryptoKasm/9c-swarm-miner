#!/bin/bash

Y="\e[93m"
M="\e[95m"
C="\e[96m"
G="\e[92m"
Re="\e[91m"
R="\e[0m"
RL="\e[1A\e["
RDL="\e[4A\e["

NC_SNAPDIR="latest-snapshot"
NC_SNAPSHOT="$NC_SNAPDIR/9c-main"
NC_SNAPZIP="9c-main-snapshot.zip"

# Exit with reason
error_exit()
{
  echo "$1" 1>&2
  exit 1
}

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
        echo -e "$C   -Importing:$R$G settings.conf$R"
        source settings.conf
    else
        echo -e "$Re  -Run setup.sh before running this script!$R"
        exit 1
    fi
}

# Check: buildparams.txt
checkBuildParams() {
    if [ -f "buildparams.txt" ]; then
        echo -e "$C   -Importing:$R$G buildparams.txt$R"
        source buildparams.txt
    else
        echo -e "$Re  -Run setup.sh before running this script!$R"
        exit 1
    fi
}

# Copy: Snapshot to Volumes
copyVolume(){
    echo -e "$M>Preparing Volumes on Platform$R"
    
    for ((i=1; i<=$NC_MINERS; i++)); do
        echo -e "$C   -Volume>$R$M 9c-swarm-miner_swarm-miner$((i))_1:$R$G Copying...$R"
        # NOTE: The location and the name of the docker volumes may differ, depending on the system.
        sudo docker cp . 9c-swarm-miner_swarm-miner$((i))_1:/app/data/
        echo -e "$RL2$C   -Volume>$R$M 9c-swarm-miner_swarm-miner$((i))_1:$R$G Done       $R"
    done
}

# Refresh: Snapshot
refreshSnapshot() {
    echo -e "$M>Refreshing Snapshot$R"

    echo -e "$C   -Cleaning Docker Environment:$R$Y Processing...$R"
    {
    docker-compose down -v --remove-orphans     # Stops & deletes environment **snapshot**
    docker-compose up -d        # Restarts to recreate clean environment
    docker-compose stop         # Stops cleaned environment for snapshot update
    } &> /dev/null
    echo -e "$RL$C   -Cleaning Docker Environment:$R$G Done          $R"

    echo -e "$C   -Searching for Snapshot:$R$Y Checking...$R"

    if [ -d "$NC_SNAPSHOT" ]; then
        echo -e "$RL$C   -Searching for Snapshot:$R$G Found       $R"
        echo -e "$C   -Cleaning Local Snapshot:$R$Y Processing...$R"
        rm -f $NC_SNAPZIP
        rm -rf latest-snapshot/* &> /dev/null
        echo -e "$RL$C   -Cleaning Local Snapshot:$R$G Done          $R"
    else
        echo -e "$RL$C   -Searching for Snapshot:$R$Y Not Found   $R"
        mkdir -p latest-snapshot &> /dev/null
    fi

    echo -e "$C   -New Snapshot:$R$Y Downloading...$R"
    cd latest-snapshot
    curl -O $SNAPSHOT
    echo -e "$C   -New Snapshot:$R$G Done           $R"
    
    echo -e "$C   -Unzipping Snapshot:$R$Y Processing...$R"
    unzip 9c-main-snapshot.zip &> /dev/null
    echo -e "$RL$C   -Unzipping Snapshot:$R$G Done          $R"

    mv 9c-main-snapshot.zip ../

    copyVolume
}

# Test: Refresh if older than 2 hrs
testAge() {
    if [ -d "$NC_SNAPSHOT" ] && [ -d "$NC_SNAPZIP" ]; then
        sudo chmod -R 700 $NC_SNAPSHOT
        if [[ $(find $NC_SNAPZIP -type f +mmin +120) ]]; then
            refreshSnapshot
        else
            echo -e "$C   -Snapshot:$R$Y Current! (Force refresh with -f flag)$R"
        fi
    else
        refreshSnapshot
    fi
}

forceRefresh() {
    echo -e "$M>Snapshot Management: $(checkPlatform)$R"

    checkConfig
    checkBuildParams
    refreshSnapshot
}

###############################
snapshotMain() {
    echo -e "$M>Snapshot Management: $(checkPlatform)$R"
    
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