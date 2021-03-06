#!/bin/bash
source bin/cklib.sh

# Check: ROOT
checkRoot

# Install: Curl
installCurl() {
    startSpinner "Installing curl:"
    if ! [ -x "$(command -v curl)" ]; then
        sudo apt install curl -y &> /dev/null

        if ! [ -x "$(command -v curl)" ]; then
            errCode "Can't install 'curl'"
        fi
    fi
    stopSpinner $?
}

# Install: Unzip
installUnzip() {
    startSpinner "Installing unzip:"
    if ! [ -x "$(command -v unzip)" ]; then
        sudo apt install unzip -y &> /dev/null

        if ! [ -x "$(command -v unzip)" ]; then
            errCode "Can't install 'unzip'"
        fi
    fi
    stopSpinner $?
}

# Install: Docker
installDocker() {
    startSpinner "Installing docker:"
    if ! [ -x "$(command -v docker)" ]; then
        if [ $(checkPlatform) = "NATIVE" ]; then
            # Removing leftovers if Docker is not found
            {
                sudo apt remove --yes docker docker-engine docker.io containerd runc
                sudo apt update
                sudo apt --yes --no-install-recommends install apt-transport-https ca-certificates

                wget --quiet --output-document=- https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
                sudo add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release --codename --short) stable"
                sudo apt update

                sudo apt --yes --no-install-recommends install docker-ce docker-ce-cli containerd.io
                sudo usermod --append --groups docker "$USER"
                sudo systemctl enable docker
            } &> /dev/null

            if ! [ -x "$(command -v unzip)" ]; then
                stopSpinner $?
                errCode "Can't install 'docker'"
            fi
        else
            stopSpinner $?
            errCode "Start Docker Desktop on Wondows"
        fi
    fi
    stopSpinner $?
}

# Install: Docker-Compose
installCompose() {
    startSpinner "Installing docker-compose:"
    # Get: Compose Latest Version
    compose_release() {
        curl --silent "https://api.github.com/repos/docker/compose/releases/latest" |
        grep -Po '"tag_name": "\K.*?(?=")'
    }

    if ! [ -x "$(command -v docker-compose)" ]; then
        sudo curl -# -L https://github.com/docker/compose/releases/download/$(compose_release)/docker-compose-$(uname -s)-$(uname -m) \
            -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose

        if ! [ -x "$(command -v unzip)" ]; then
            stopSpinner $?
            errCode "Can't install 'docker-compose'"
        fi
    fi
    stopSpinner $?
}

# Install: JQ
installJq() {
    startSpinner "Installing jq:"
    if ! [ -x "$(command -v jq)" ]; then
        sudo apt install jq -y &> /dev/null

        if ! [ -x "$(command -v jq)" ]; then
            errCode "Can't install 'jq'"
        fi
    fi
    stopSpinner $?
}

# Install: zip
installZip() {
    startSpinner "Installing zip:"
    if ! [ -x "$(command -v zip)" ]; then
        sudo apt install zip -y &> /dev/null

        if ! [ -x "$(command -v zip)" ]; then
            errCode "Can't install 'zip'"
        fi
    fi
    stopSpinner $?
}

# Install: postfix
installPostFix() {
    startSpinner "Installing postfix:"
    if ! [ -x "$(command -v postfix)" ]; then
        sudo apt install debconf-utils -y &> /dev/null
        echo "postfix postfix/mailname string example.com" | sudo debconf-set-selections
        echo "postfix postfix/main_mailer_type string 'Internet Site'" | sudo debconf-set-selections
        sudo apt install postfix -y &> /dev/null

        if ! [ -x "$(command -v postfix)" ]; then
            errCode "Can't install 'postfix'"
        fi
    fi
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

    Ser=$(pgrep cron)
    if [[ -z $Ser ]]; then
        sudo service cron start
        echo -ne "\nsudo -i service cron start\n" >> /home/$USER/.bashrc
    fi
    stopSpinner $?
}

# Build: Settings.conf
buildConfig() {
    if [ -f "settings.conf" ]; then
        sEntry "Found settings.conf"
        source settings.conf
    else
        ./bin/build-config.sh
    fi
}

# Build: docker-compose.yml
buildCompose() {
    ./bin/build-compose.sh
}

# Check: Permissions
checkPerms() {
    startSpinner "Setting permissions:"
    if [ -f 9c-swarm-miner.sh ]; then chmod +xrw 9c-swarm-miner.sh; fi
    if [ -f docker-compose.yml ]; then chmod +rw docker-compose.yml; fi
    if [ -f settings.conf ]; then chmod +rw settings.conf; fi
    if [ -f bin/build-config.sh ]; then chmod +x bin/build-config.sh; fi
    if [ -f bin/build-compose.sh ]; then chmod +xrw bin/build-compose.sh; fi
    if [ -f bin/manage-snapshot.sh ]; then chmod +x bin/manage-snapshot.sh; fi
    if [ -f bin/setup.sh ]; then chmod +x bin/setup.sh; fi
    if [ -f bin/crontab.sh ]; then chmod +x bin/crontab.sh; fi
    if [ -f bin/cklib.sh ]; then chmod +x bin/cklib.sh; fi
    if [ -f bin/graphql-query.sh ]; then chmod +x bin/graphql-query.sh; fi
    if [ -f bin/email.sh ]; then chmod +x bin/email.sh; fi
    if [ -f bin/key.sh ]; then chmod +x bin/key.sh; fi
    if [ -f /usr/local/bin/docker-compose ]; then sudo chmod +x /usr/local/bin/docker-compose; fi
    stopSpinner $?
}

# Sudo apt update
checkAptUpdate() {
    startSpinner "Checking for APT updates:"
    sudo apt update &> /dev/null
    stopSpinner $?
}

# Dispaly text if first setup
relogginText() {
    sLL
    sTitle "Log out and then log in to complete the setup! Then re-run this script!"
    echo
}

# Dispaly text if updating
updateText() {
    sLL
    sTitle "Update complete!"
    echo
}
###############################
setupMain() {
    sTitle "Initiating Setup for $(checkPlatform)"
    checkAptUpdate
    installCurl
    installUnzip
    installDocker
    installCompose
    installJq
    installZip
    installPostFix
    checkPerms
    installCronTab
    buildConfig
    buildCompose
}
###############################
case $1 in

  --update)
    setupMain
    updateText
    exit 0
    ;;

  *)
    setupMain
    relogginText
    exit 0
    ;;

esac