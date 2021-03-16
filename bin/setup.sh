#!/bin/bash
source bin/cklib.sh

#| Check: ROOT
cRoot

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
        if [ $(cPlatform) = "NATIVE" ]; then
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
    ./bin/email.sh
}

# Install: CronTab
installCronTab() {
    ./bin/crontab.sh
}

# Build: Settings.conf
buildConfig() {
    ./bin/build-config.sh
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
    if [ -f /usr/local/bin/docker-compose ]; then sudo chmod +x /usr/local/bin/docker-compose; fi
    stopSpinner $?
}

# Sudo apt update
checkAptUpdate() {
    startSpinner "Checking for APT updates:"
    sudo apt update &> /dev/null
    stopSpinner $?
}

###############################
setupMain() {
    sTitle "Initiating Setup for $(cPlatform)"
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
    sLL
    sTitle "Log out and then log in to complete the setup! Then re-run this script!"
    echo
}
###############################
if [ "$1" == "--perms" ]; then
    checkPerms
    exit 0
else
    setupMain
    exit 0
fi