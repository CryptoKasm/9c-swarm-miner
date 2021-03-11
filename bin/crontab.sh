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
    stopSpinner $?
}

# Disable: Cron
disableCron() {
    startSpinner "Disabled crontab entry:"
    ( sudo crontab -l | grep -v -F "$CronPath" ) | sudo crontab -
    ( sudo crontab -l | grep -v -F "$CronCMD" ) | sudo crontab -
    stopSpinner $?
}

# Install: CronTab
installCronTab() {
    startSpinner "Checking crontab:"
    if ! [ -x "$(command -v cron)" ]; then
        sudo apt install cron -y &> /dev/null

        if ! [ -x "$(command -v cron)" ]; then 
            errCode "Can't install 'cron'" 
        fi
    fi
    
    Ser=$(pgrep $CronService)
    if [[ -z $Ser ]]; then
        sudo service cron start
        echo -ne "\nsudo -i service cron start\n" >> /home/$USER/.bashrc
    fi
    stopSpinner $?
}

###############################
cronMain() {
    sL
    sTitle "CronTab"
}
###############################
if [ "$1" == "--enable" ]; then
    cronMain
    enableCron
    exit 0
elif [ "$1" == "--disable" ]; then
    cronMain
    disableCron
    exit 0
else
    cronMain
    installCronTab
    exit 0
fi