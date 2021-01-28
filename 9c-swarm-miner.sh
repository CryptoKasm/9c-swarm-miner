#!/bin/bash

Y="\e[93m"
M="\e[95m"
C="\e[96m"
G="\e[92m"
R="\e[0m"

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

# Check: Run setup if first run
checkFirstRun() {
    if [ -f "settings.conf" ] || [ -f "docker-compose.yml" ]; then
        return
    else
        ./bin/setup.sh
    fi
}

# Check: settings.conf
checkConfig() {
    if [ -f "settings.conf" ]; then
        echo -e "$C   -Importing:$R$G settings.conf$R"
        source settings.conf
    else
        ./bin/build-config.sh
    fi
}

# Check: docker-compose.yml
checkCompose() {
    if [ -f "docker-compose.yml" ]; then
        echo -e "$C   -Importing:$R$G docker-compose.yml$R"
        source settings.conf
    else
        ./bin/build-compose.sh
    fi
}

# Check: Snapshot
checkSnapshot() {
    if [[ "$NC_REFRESH_SNAPSHOT" == 1 ]]; then
        ./bin/manage-snapshot.sh
        #TODO Need to test on Native Linux before official release
    else
        echo -e "$M>Snapshot Management:$R$Y Disabled$R"
    fi
}

# Precheck
preCheck() {
    echo -e "$M>Loading Prerequisites$R"
    checkConfig
    checkCompose
}

# Start Docker Containers
startDocker() {
    echo -e "$M>Starting Docker$R"
    echo -e "$Y------------------$R"
    docker-compose up -d 
    echo -e "$Y-----------------------------------------------$R"
    echo -e "$Y-Windows Monitor (Full Log): $R"
    echo -e "$G    Goto Docker and you can access logging for each individual container $R"
    echo -e "$Y-Windows Monitor (Mined Blocks Only): $R"
    echo -e "$G    Search for Mined a block $R"
    echo -e "$Y-Linux Monitor (Full Log): $R"
    echo -e "$G    docker-compose logs --tail=100 -f $R"
    echo -e "$Y-Linux Monitor (Mined Blocks Only): $R"
    echo -e "$G    docker-compose logs --tail=100 -f | grep -A 10 --color -i 'Mined a block' $R"
    echo -e "$Y-Linux Monitor (Mined/Reorg/Append failed events): $R"
    echo -e "$G    docker-compose logs --tail=1 -f | grep --color -i -E 'Mined a|reorged|Append failed' $R"
    echo -e "$Y-----------------------------------------------$R"

}

###############################
Main() {
    echo -e "$Y-----------------------------------------------$R"
    echo -e "$Y>Nine Chronicles - Swarm Miner by CryptoKasm$R"
    echo -e "$Y>Version:$R$G 1.4.1-alpha$R"
    echo -e "$Y>Platform:$R$G $(checkPlatform)$R"
    echo -e "$Y-----------------------------------------------$R"
    checkFirstRun
    preCheck
    checkSnapshot
    startDocker
}
###############################
if [ "$1" == "--setup" ]; then
    ./bin/setup.sh
    exit 0
elif [ "$1" == "--update" ]; then
    ./bin/build-compose.sh
elif [ "$1" == "--refresh" ]; then
    ./bin/manage-snapshot.sh
elif [ "$1" == "--force-refresh" ]; then
    ./bin/manage-snapshot.sh --force
elif [ "$1" == "--clean" ]; then
    rm -r docker-compose.yml
    rm -rf latest-snapshot
elif [ "$1" == "--clean-all" ]; then
    rm -r docker-compose.yml
    rm -f settings.conf
    rm -rf latest-snapshot
else
    Main
    exit 0
fi