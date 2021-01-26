#!/bin/bash

if [ -f "settings.conf" ]; then
    source settings.conf
else
    echo "No configuration file..."
fi


# Check: Platform (Native Linux or WSL)
checkPlatform() {
    if grep -q icrosoft /proc/version; then
        echo "> Platform: Ubuntu on Windows (WSL)"
        PLATFORM="WSL"
    else
        echo "> Platform: Native Linux"
        PLATFORM="NATIVE"
    fi
}

# Check: Prerequisites
checkPrereqs() {
    echo "> Checking for Prerequisites"

    if ! [ -x "$(command -v git)" ]; then
        echo "   --Git: Installing..."
        sudo apt install -y git
    else 
        echo "   --Git: Installed."
    fi
    if ! [ -x "$(command -v curl)" ]; then
        echo "   --Curl: Installing..."
        sudo apt install -y curl
    else 
        echo "   --Curl: Installed."
    fi
    if ! [ -x "$(command -v unzip)" ]; then
        echo "   --Unzip: Installing..."
        sudo apt install -y unzip
    else 
        echo "   --Unzip: Installed."
    fi
}

# Docker: Install
checkDocker() {
    echo "> Checking for Docker"
    if ! [ -x "$(command -v docker)" ]; then
        if [ $PLATFORM = "NATIVE" ]; then
            echo "   --Installing..."
            # Removing leftovers if Docker is not found
            sudo apt remove --yes docker docker-engine docker.io containerd runc
            sudo apt update
            sudo apt --yes --no-install-recommends install apt-transport-https ca-certificates
            wget --quiet --output-document=- https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
            sudo add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release --codename --short) stable"
            sudo apt update
            sudo apt --yes --no-install-recommends install docker-ce docker-ce-cli containerd.io
            sudo usermod --append --groups docker "$USER"
            sudo systemctl enable docker

            echo
            echo "> Please log out and log in to complete the setup! Then rerun this script"
        else
            echo "   --Run Docker Desktop on Windows and rerun this script!"
        fi
    else 
        echo "   --Installed."
    fi
}

# Check: Compose
checkCompose() {
    echo "> Checking for Compose"

    # Get: Compose Latest Version
    compose_release() {
        curl --silent "https://api.github.com/repos/docker/compose/releases/latest" |
        grep -Po '"tag_name": "\K.*?(?=")'
    }

    if ! [ -x "$(command -v docker-compose)" ]; then
        echo "   --Installing..."
        curl -L https://github.com/docker/compose/releases/download/$(compose_release)/docker-compose-$(uname -s)-$(uname -m) \
        -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
    else 
        echo "   --Installed."
    fi
}

# Check: Permissions
checkPerms() {
    # TODO Set proper perms for files
    echo "> Setting Permissions"
    
    if [ -f 9c-swarm-miner.sh ]; then chmod +xrw 9c-swarm-miner.sh; else echo "   --9c-swarm-miner.sh not found"; fi
    if [ -f docker-compose.yml ]; then chmod +rw docker-compose.yml; else echo "   --docker-compose.yml not found"; fi
    if [ -f settings.conf ]; then chmod +rw settings.conf; else echo "   --settings.conf not found"; fi

    if [ -f bin/build_config.sh ]; then chmod +rw bin/build_config.sh; else echo "   --build_config.sh not found"; fi
    if [ -f bin/docker-compose.sh ]; then chmod +rw bin/docker-compose.sh; else echo "   --docker-compose.yml not found"; fi
    if [ -f bin/snapshot.sh ]; then chmod +rw bin/snapshot.sh; else echo "   --snapshot.sh not found"; fi
    if [ -f bin/system.sh ]; then chmod +rw bin/system.sh; else echo "   --system.sh not found"; fi
}

setupSystem() {
    checkPlatform
    checkPrereqs
    checkDocker
    checkCompose
    checkPerms
}

#############################################
# Main

if [ "$1" == "--Platform" ]; then
    checkPlatform
    exit 0
fi

if [ "$1" == "--Prereqs" ]; then
    checkPrereqs
    exit 0
fi

if [ "$1" == "--Docker" ]; then
    checkDocker
    exit 0
fi

if [ "$1" == "--Compose" ]; then
    checkCompose
    exit 0
fi

if [ "$1" == "--Permissions" ]; then
    checkPerms
    exit 0
fi

if [ "$1" == "--Setup" ]; then
    setupSystem
    exit 0
fi

#
#############################################