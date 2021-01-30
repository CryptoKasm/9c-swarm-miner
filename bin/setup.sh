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

# Install: Curl
installCurl() {
    consoleEntry "3" "1" "1" "1"
    if ! [ -x "$(command -v curl)" ]; then
        consoleEntry "3" "1" "3" "1"
        sudo apt install curl -y &> /dev/null
        consoleEntry "3" "1" "8" "1"

        if [ -x "$(command -v curl)" ]; then 
            consoleEntry "3" "2" "10" "0"
        else 
            errCode "Can't install 'Curl'" 
        fi
    else 
        consoleEntry "3" "2" "10" "0"
    fi
}

# Install: Unzip
installUnzip() {
    consoleEntry "4" "1" "1" "1"
    if ! [ -x "$(command -v unzip)" ]; then
        consoleEntry "4" "1" "3" "1"
        sudo apt install unzip -y &> /dev/null
        consoleEntry "4" "2" "8" "0"

        if [ -x "$(command -v unzip)" ]; then 
            consoleEntry "4" "2" "10" "0"
        else 
            errCode "Can't install 'Unzip'" 
        fi
    else 
        consoleEntry "4" "2" "10" "0"
    fi
}

# Install: Docker
installDocker() {
    # TODO: Test on Dev Machine where I can freely uninstall/reinstall docker.
    consoleEntry "1" "1" "1" "1"
    if ! [ -x "$(command -v docker)" ]; then
        if [ $(checkPlatform) = "NATIVE" ]; then
            consoleEntry "1" "2" "3" "1"
            # Removing leftovers if Docker is not found
            {
            sudo apt remove --yes docker docker-engine docker.io containerd runc
            sudo apt update
            sudo apt --yes --no-install-recommends install apt-transport-https ca-certificates
            } &> /dev/null
            consoleEntry "1" "1" "5" "1"
            {
            wget --quiet --output-document=- https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
            sudo add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release --codename --short) stable"
            sudo apt update
            } &> /dev/null
            consoleEntry "1" "1" "8" "1"
            {
            sudo apt --yes --no-install-recommends install docker-ce docker-ce-cli containerd.io
            sudo usermod --append --groups docker "$USER"
            sudo systemctl enable docker
            } &> /dev/null

            if [ -x "$(command -v unzip)" ]; then 
                consoleEntry "1" "2" "10" "0"
            else 
                errCode "Can't install 'Docker'" 
            fi
        else
            consoleEntry "1" "7" "9" "0"          
        fi
    else 
        consoleEntry "1" "2" "10" "0"
    fi
}

# Install: Docker-Compose
installCompose() {
    consoleEntry "2" "1" "1" "1"
    # Get: Compose Latest Version
    compose_release() {
        curl --silent "https://api.github.com/repos/docker/compose/releases/latest" |
        grep -Po '"tag_name": "\K.*?(?=")'
    }

    if ! [ -x "$(command -v docker-compose)" ]; then
        consoleEntry "2" "1" "3" "1"
        sudo curl -# -L https://github.com/docker/compose/releases/download/$(compose_release)/docker-compose-$(uname -s)-$(uname -m) \
        -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose
        consoleEntry "2" "1" "8" "1"
        
        if [ -x "$(command -v unzip)" ]; then 
            consoleEntry "2" "2" "10" "0"
        else 
            errCode "Can't install 'Docker-Compose'" 
        fi
    else 
        consoleEntry "2" "2" "10" "0"
    fi
}

# Check: Permissions
checkPerms() {
    consoleEntry "5" "8" "1" "1"
    if [ -f 9c-swarm-miner.sh ]; then chmod +xrw 9c-swarm-miner.sh; fi
    consoleEntry "5" "8" "2" "1"
    if [ -f docker-compose.yml ]; then chmod +rw docker-compose.yml; fi
    consoleEntry "5" "8" "3" "1"
    if [ -f settings.conf ]; then chmod +rw settings.conf; fi
    consoleEntry "5" "8" "4" "1"
    if [ -f bin/build-config.sh ]; then chmod +x bin/build-config.sh; fi
    consoleEntry "5" "8" "5" "1"
    if [ -f bin/build-compose.sh ]; then chmod +x bin/build-compose.sh; fi
    consoleEntry "5" "8" "6" "1"
    if [ -f bin/manage-snapshot.sh ]; then chmod +x bin/manage-snapshot.sh; fi
    consoleEntry "5" "8" "7" "1"
    if [ -f bin/setup.sh ]; then chmod +x bin/setup.sh; fi
    consoleEntry "5" "8" "8" "1"
    if [ -f bin/consoleStyle.sh ]; then chmod +x bin/consoleStyle.sh; fi
    consoleEntry "5" "8" "9" "1"
    if [ -f bin/cronjob.sh ]; then chmod +x bin/cronjob.sh; fi
    consoleEntry "5" "8" "9" "1"
    if [ -f /usr/local/bin/docker-compose ]; then sudo chmod +x /usr/local/bin/docker-compose; fi
    consoleEntry "5" "9" "10" "0"
}

###############################
setupMain() {
    consoleTitle "Initiating Setup for $(checkPlatform)"
    installCurl
    installUnzip
    installDocker
    installCompose
    checkPerms
}
###############################
if [ "$1" == "--perms" ]; then
    checkPerms
    exit 0
else
    setupMain
    exit 0
fi