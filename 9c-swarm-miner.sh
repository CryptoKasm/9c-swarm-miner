#!/bin/bash
source bin/cklib.sh

#| Check: ROOT
cRoot

# Check: Run setup if first run
checkFirstRun() {
    if [ ! -f "settings.conf" ] && [ ! -f "docker-compose.yml" ]; then
        ./bin/setup.sh
    else
        return
    fi
    exit 0
}

# Check: settings.conf
checkConfig() {
    if [ -f "settings.conf" ]; then
        sEntry "settings.conf"
        source settings.conf
    else
        ./bin/build-config.sh
    fi
}

# Check: docker-compose.yml
checkCompose() {
    if [ -f "docker-compose.yml" ]; then
        rm -f docker-compose.yml
        ./bin/build-compose.sh
    else
        ./bin/build-compose.sh
    fi
}

# Check: Snapshot
checkSnapshot() {
    sL
    if [[ "$NC_REFRESH_SNAPSHOT" == 1 ]]; then
        ./bin/manage-snapshot.sh
    else
        sTitle "Snapshot Management:$C Disabled"
    fi
}

# Precheck
preCheck() {
    sTitle "Loading Prerequisites"
    checkConfig
    checkCompose
}

# Autostart: Logging Docker Containers
autoLog() {
    sLL
    sTitle "Auto Logging Filers: Mined a block | reorged | Append failed"
    export GREP_COLORS='ms=1;92'
    docker-compose logs --tail=1000 -f | grep --color -i -E 'Mined a block|reorged|Append failed'
}

# Display Log Commands
displayLogCmds() {
    sLL
    sTitle "Windows Monitor (Full Log):"
    sAction "Open Docker and you can access logging for each individual container"
    sTitle "Windows Monitor (Mined Blocks Only):"
    sAction "Search for 'Mined a block'"
    sTitle "Linux Monitor (Full Log):"
    sAction "docker-compose logs --tail=100 -f"
    sTitle "Linux Monitor (Mined Blocks Only):"
    sAction "docker-compose logs --tail=100 -f | grep -A 10 --color -i 'Mined a block'"
    sTitle "Linux Monitor (Mined/Reorg/Append failed events):"
    sAction "docker-compose logs --tail=1 -f | grep --color -i -E 'Mined a block|reorged|Append failed'"
}

# Start Docker Containers
startDocker() {
    sL
    sTitle "Docker"
    startSpinner "Initiating containers:"
    { 
        docker-compose up -d
    } &> /dev/null
    stopSpinner $?
}

###############################
Main() {
    sIntro
    checkFirstRun
    preCheck
    checkSnapshot
    startDocker
    displayLogCmds
    autoLog
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
    rm -r 9c-main-snapshot.zip
else
    Main
    exit 0
fi