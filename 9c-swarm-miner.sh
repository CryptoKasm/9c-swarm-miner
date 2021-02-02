#!/bin/bash
source bin/cklib.sh

# Check: ROOT
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

# Check: Crontab
checkCronTab() {
    if [[ "$NC_CRONJOB_AUTO_RESTART" == 0 ]]; then
        ./bin/crontab.sh --disable
    else
        ./bin/crontab.sh --enable
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

# Cleanup
clean() {
    if [[ "$1" == "1" ]]; then
        sudo rm -f docker-compose.yml
        sudo rm -rf latest-snapshot
        sudo rm -f 9c-main-snapshot.zip
        sudo rm -rf logs
    elif [[ "$1" == "2" ]]; then
        sudo rm -f docker-compose.yml
        sudo rm -f settings.conf
        sudo rm -rf latest-snapshot
        sudo rm -f 9c-main-snapshot.zip
        sudo rm -rf vault
        sudo rm -rf logs
    else
        errCode "Not a valid cleaning option."
    fi
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

# Update
updateMain() {
    sIntro
    sTitle "Checking for updates"

    startSpinner "Cleaning old files:"
    clean "1"
    stopSpinner $?

    startSpinner "Pulling from Github:"
    {
        git pull
    } &> /dev/null
    stopSpinner $?

    ./bin/build-config.sh --update

    ./bin/setup.sh --perms
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
    checkCronTab
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
    updateMain
    exit 0
elif [ "$1" == "--perms" ]; then
    ./bin/setup.sh --perms
    exit 0
elif [ "$1" == "--crontab" ]; then
    cd /home/$USER/9c-swarm-miner
    rm -f 9c-main-snapshot.zip
    docker-compose down -v --remove-orphans
    Main
elif [ "$1" == "--refresh" ]; then
    ./bin/manage-snapshot.sh
elif [ "$1" == "--force-refresh" ]; then
    ./bin/manage-snapshot.sh --force
elif [ "$1" == "--clean" ]; then
    sudo rm -f docker-compose.yml
    sudo rm -rf latest-snapshot
    sudo rm -f 9c-main-snapshot.zip
    sudo rm -rf logs
elif [ "$1" == "--clean-all" ]; then
    sudo rm -f docker-compose.yml
    sudo rm -f settings.conf
    sudo rm -rf latest-snapshot
    sudo rm -f 9c-main-snapshot.zip
    sudo rm -rf vault
    sudo rm -rf logs
else
    Main
    exit 0
fi