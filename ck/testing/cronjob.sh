#!/bin/bash

CronCMD="/home/$USER/9c-swarm-miner/bin/cronjob.sh > /home/blaque/9c-swarm-miner/logs/cron.log 2>&1"
CronJob="*/2 * * * * $CronCMD"
CronService="sudo -i service cron start"

# Test: Root Privileges
if [ "$EUID" -ne 0 ]; then
    sudo echo -ne "\r"
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

#Setup: Crontab
if [ $(checkPlatform) = "WSL" ]; then
    echo -e "\nsudo -i service cron start\n" >> /home/blaque/.bashrc
    
    ( crontab -l | grep -v -F "$CronCMD" ; echo "$CronJob" ) | crontab -
elif [ $(checkPlatform) = "NATIVE" ]; then
    ( crontab -l | grep -v -F "$CronCMD" ; echo "$CronJob" ) | crontab -
else
    errCode "Couldn't identify your OS!"
fi

###############################
cronMain() {
    echo $(checkPlatform)

}
###############################
if [ "$1" == "--perms" ]; then
    checkPerms
    exit 0
else
    cronMain
    exit 0
fi