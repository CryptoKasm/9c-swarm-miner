#!/bin/bash
source bin/cklib.sh

# Check: ROOT
checkRoot

# Set permissions for this project
checkPermissions() {
    # Set directory permissions
    sudo find . -type d -exec chmod 755 {} \;

    # Set file permissions
    sudo find . -type f -exec chmod 644 {} \;

    # Set scripts as executable
    sudo find . -name "*.sh" -exec chmod +x {} \;
}

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
    if [[ "$NC_REFRESH_SNAPSHOT" == 1 ]]; then
        ./bin/manage-snapshot.sh
    else
        sL
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
        sudo rm -rf vault
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
    sTitle "Auto Logging Filters: Mined a block | reorged | mining | Append failed"
    export GREP_COLORS='ms=1;92'
    docker-compose logs --tail=1000 -f | grep --color -i -E 'Mined a block|reorged|mining|Append failed'
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
    sAction "docker-compose logs --tail=100 -f | grep --color -i -E 'Mined a block|reorged|mining|Append failed'"
}

# Asks if user wants to start logging
runLogging() {
    sSpacer
    read -r -p "$(echo -e "$S""> Would you like to run auto-logging ['Mined a block|reorged|Append failed'] (Y/n)?: ""$RS")" optionLog
    if [[ $optionLog == [yY] || $optionLog == [yY][eE][sS] ]]; then
        autoLog
    else
        exit 0
    fi
}

# Update
updateMain() {
    sIntro
    sTitle "Checking for updates"

    startSpinner "Shutting down docker containers:"
    docker-compose down -v &> /dev/null
    stopSpinner $?

    startSpinner "Cleaning old files:"
    clean "1"
    stopSpinner $?

    startSpinner "Pulling from Github:"
    {
        git pull
    } &> /dev/null
    stopSpinner $?

    ./bin/build-config.sh --update

    ./bin/setup.sh --update
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

# Check: Docker Logs
checkDockerLog() {
    if [[ "$NC_EMAIL" == 0 ]]; then
        ./bin/email.sh --disable
    else
        ./bin/email.sh --enable
    fi
}

###############################
Main() {
    sIntro
    checkPermissions
    checkFirstRun
    preCheck
    checkCronTab
    checkDockerLog
    checkSnapshot
    startDocker
    displayLogCmds
    optionDonate
    runLogging
}
###############################
case $1 in

  --start)
    docker-compose up -d
    exit 0
    ;;

  --stop)
    docker-compose stop
    exit 0
    ;;
    
  --update)
    updateMain
    exit 0
    ;;
 
  --setup)
    ./bin/setup.sh
    exit 0
    ;;
 
  --refresh)
    ./bin/manage-snapshot.sh
    exit 0
    ;;
 
  --force-refresh)
    ./bin/manage-snapshot.sh --force
    exit 0
    ;;
 
  --clean)
    clean "1"
    exit 0
    ;;
 
  --clean-all)
    clean "2"
    exit 0
    ;;
 
  --check-vol)
    ./bin/manage-snapshot.sh --volume
    exit 0
    ;;
  
  --check-permissions)
    checkPermissions
    exit 0
    ;;

  --logging)
    displayLogCmds
    exit 0
    ;;
 
  --crontab)
    docker-compose stop
    docker-compose up -d
    exit 0
    ;;
 
  --send-logs)
    ./bin/email.sh --send
    exit 0
    ;;
 
  --check-gold)
    ./bin/graphql-query.sh --check-gold
    exit 0
    ;;

  --help)
    #TODO Add help text to explain each command and usage
    exit 0
    ;;

  --private-key)
    ./bin/key.sh --private
    exit 0
    ;;

  --public-key)
    ./bin/key.sh --public
    exit 0
    ;;

  --keys)
    ./bin/key.sh --all
    exit 0
    ;;
    
  *)
    Main
    exit 0
    ;;

esac