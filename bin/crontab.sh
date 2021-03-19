#!/bin/bash
source bin/cklib.sh

# Check: ROOT
checkRoot

# Check: Settings.conf
checkSettings

# Variables
CronPath="PATH=/bin:/usr/bin:/usr/local/bin"
CronCMD="cd /home/$USER/9c-swarm-miner && ./9c-swarm-miner.sh --crontab >> /home/$USER/9c-swarm-miner/logs/cron.log 2>&1"
CronJob="* */$NC_CRONJOB_AUTO_RESTART * * * $CronCMD"
CronService="cron"

# Create Log folder
if [ ! -d "logs" ]; then
    mkdir -p logs
fi


# Enable: Cron
enableCron() {
    startSpinner "Enabled crontab entry:"
    ( sudo crontab -l | grep -v -F "$CronPath" ; echo "$CronPath" ) | sudo crontab -
    ( sudo crontab -l | grep -v -F "$CronCMD" ; echo "$CronJob" ) | sudo crontab -
    cron_process_id=$(pidof cron)
    if [[ -z $cron_process_id ]]; then
        sudo cron
    fi
    stopSpinner $?
}

# Disable: Cron
disableCron() {
    startSpinner "Disabled crontab entry:"
    ( sudo crontab -l | grep -v -F "$CronPath" ) | sudo crontab -
    ( sudo crontab -l | grep -v -F "$CronCMD" ) | sudo crontab -
    stopSpinner $?
}

###############################
cronMain() {
    sL
    sTitle "CronTab"
}
###############################
case $1 in

  --enable)
    cronMain
    enableCron
    exit 0
    ;;

  --disable)
    cronMain
    disableCron
    exit 0
    ;;

  *)
    cronMain
    exit 0
    ;;

esac