#!/bin/bash
source bin/consoleStyle.sh

# Test: Root Privileges
if [ "$EUID" -ne 0 ]; then
    sudo echo ""
fi

# Check: Platform (Native Linux or WSL)
checkPlatform() {
    if grep -q icrosoft /proc/version; then
        PLATFORM="WSL"
    else
        PLATFORM="NATIVE"
    fi
    echo $PLATFORM
}

# Exits script from function
endScript() {
    exit 0
}

# Check: Run setup if first run
checkFirstRun() {
    if [ -f "settings.conf" ] || [ -f "docker-compose.yml" ]; then
        return
    else
        ./bin/setup.sh
        echo
        checkConfig
        checkCompose
        echo
        echo -e $P">$sB If Docker was installed, log out and log in to complete the setup! Then re-run this script!"$RS
        echo
        #endScript
    fi
}

# Check: settings.conf
checkConfig() {
    if [ -f "settings.conf" ]; then
        consoleEntry "6" "4" "0" "0"
        source settings.conf
    else
        ./bin/build-config.sh
    fi
}

# Check: docker-compose.yml
checkCompose() {
    if [ -f "docker-compose.yml" ]; then
        consoleEntry "7" "4" "0" "1"
        ./bin/build-compose.sh
    else
        ./bin/build-compose.sh
    fi
}

# Check: Snapshot
checkSnapshot() {
    echo -e $P"-----------------------------------------------"$RS
    if [[ "$NC_REFRESH_SNAPSHOT" == 1 ]]; then
        ./bin/manage-snapshot.sh
    else
        consoleTitle "Snapshot Management:$F Disabled$RS"
    fi
}

# Precheck
preCheck() {
    consoleTitle "Loading Prerequisites"
    checkConfig
    checkCompose
}

# Autostart: Logging Docker Containers
autoLog() {
    export GREP_COLORS='ms=1;92'
    echo -e $P"-----------------------------------------------"$RS
    consoleTitle "Docker Logging - Mined a block | reorged | Append failed"
    docker-compose logs --tail=1000 -f | grep --color -i -E 'Mined a block|reorged|Append failed'
}

# Display Log Commands
displayLogCmds() {
    echo -e $P"-----------------------------------------------"$RS
    consoleTitle "Windows Monitor (Full Log):"
    echo -e "    Open Docker and you can access logging for each individual container"
    consoleTitle "Windows Monitor (Mined Blocks Only):"
    echo -e "    Search for Mined a block"
    consoleTitle "Linux Monitor (Full Log):"
    echo -e "    docker-compose logs --tail=100 -f"
    consoleTitle "Linux Monitor (Mined Blocks Only):"
    echo -e "    docker-compose logs --tail=100 -f | grep -A 10 --color -i 'Mined a block'"
    consoleTitle "Linux Monitor (Mined/Reorg/Append failed events):"
    echo -e "    docker-compose logs --tail=1 -f | grep --color -i -E 'Mined a block|reorged|Append failed'"
}

# Start Docker Containers
startDocker() {
    echo -e $P"-----------------------------------------------"$RS
    consoleTitle "Starting Docker"
    docker-compose up -d 
    
}

###############################
Main() {
    consoleIntro
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
elif [ "$1" == "--cron" ]; then
    ./bin/manage-snapshot.sh --force
    Main
else
    Main
    exit 0
fi