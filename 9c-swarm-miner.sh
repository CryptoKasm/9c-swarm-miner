#!/bin/bash
source bin/cklib.sh

# Check: ROOT
cRoot

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
    sAction "docker-compose logs --tail=100 -f | grep --color -i -E 'Mined a block|reorged|Append failed'"
    sSpacer
    read -p "$(echo -e $S"> Would you like to run auto-logging ['Mined a block|reorged|Append failed'] (Y/n)?: "$RS)" optionLog
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
    docker-compose down -v --remove-orphans
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

# Send Docker Logs
SendDockerLogs() {
    sL
    sTitle "Retriving Docker Logs and Emailing Support"
    startSpinner "creating attachments:"
    {
        source settings.conf
        Opath=$(pwd)/logs
        Dcontainer=/var/lib/docker/containers
        source settings.conf
        find $Opath/$Dname.*.log -type f -mtime +3 -delete
        for OUTPUT in $(docker ps -aqf "name=^9c-swarm-miner" --no-trunc)
        do
        Dname=$(docker ps -af "id=$OUTPUT" --format {{.Names}})
        `sudo cat $Dcontainer/$OUTPUT/$OUTPUT-json.log | jq '.' > $Opath/$Dname.$(date +"%Y_%m_%d_%I_%M_%p").log`
        #zip $Opath/emaildebug.$NC_PUBLIC_KEY.zip $Opath/$Dname.$(date +"%Y_%m_%d_%I_%M_%p").log
        #rm $Opath/$Dname.$(date +"%Y_%m_%d_%I_%M_%p").log
        done
    } &> /dev/null
    stopSpinner $?

    #startSpinner "Creating Email & Sending To Development Team"
    #echo "" | mail --append="FROM:$NC_PUBLIC_KEY@cryptokasm.io" -A $Opath/emaildebug.$NC_PUBLIC_KEY.zip -s "AutoLogs | 9c-swarm-miner | $NC_PUBLIC_KEY" support@cryptokasm.io -F '$NC_PUBLIC_KEY'
    #rm $Opath/emaildebug.$NC_PUBLIC_KEY.zip
    #stopSpinner $?
}

###############################
Main() {
    sIntro
    checkPermissions
    checkFirstRun
    preCheck
    checkCronTab
    checkSnapshot
    startDocker
    displayLogCmds
}
###############################
if [ "$1" == "--setup" ]; then
    ./bin/setup.sh
    exit 0
elif [ "$1" == "--update" ]; then
    updateMain
    exit 0
elif [ "$1" == "--perms" ]; then
    checkPermissions
    exit 0
elif [ "$1" == "--crontab" ]; then
    docker-compose stop
    bin/manage-snapshot.sh
    docker-compose up -d
elif [ "$1" == "--refresh" ]; then
    ./bin/manage-snapshot.sh
elif [ "$1" == "--force-refresh" ]; then
    ./bin/manage-snapshot.sh --force
elif [ "$1" == "--clean" ]; then
    clean "1"
elif [ "$1" == "--clean-all" ]; then
    clean "2"
elif [ "$1" == "--check-gold" ]; then
    ./bin/graphql-query.sh --check-gold
elif [ "$1" == "--send-logs" ]; then
    SendDockerLogs
else
    Main
    exit 0
fi