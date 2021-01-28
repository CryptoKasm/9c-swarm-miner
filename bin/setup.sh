#!/bin/bash

Y="\e[93m"
M="\e[95m"
C="\e[96m"
G="\e[92m"
Re="\e[91m"
R="\e[0m"
RL="\e[1A\e["

# Exit with reason
error_exit()
{
  echo "$1" 1>&2
  exit 1
}

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
    if ! [ -x "$(command -v curl)" ]; then
        echo -e "$C  -Curl:$R$Y Installing...$R"
        sudo apt install curl -y &> /dev/null
        echo -e "$RL$C  -Curl:$R$G Installed     $R"
    else 
        echo -e "$C  -Curl:$R$G Installed$R"
    fi
}

# Install: Unzip
installUnzip() {
    if ! [ -x "$(command -v unzip)" ]; then
        echo -e "$C  -Unzip:$R$Y Installing...$R"
        sudo apt install unzip -y &> /dev/null
        echo -e "$RL$C  -Curl:$R$G Installed     $R"
    else 
        echo -e "$C  -Unzip:$R$G Installed$R"
    fi
}

# Install: Docker
installDocker() {
    if ! [ -x "$(command -v docker)" ]; then
        if [ $(checkPlatform) = "NATIVE" ]; then
            echo -e "$C  -Docker:$R$Y Installing...$R"
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
            RESTART=1
        else
            echo -e "$C  -Docker:$R$Re Make sure to run Docker Desktop on Windows 10!"$R
            RESTART=0
            
        fi
    else 
        echo -e "$RL$C  -Docker:$R$G Installed     $R"
        RESTART=0
    fi
}

# Install: Docker-Compose
installCompose() {
    # Get: Compose Latest Version
    compose_release() {
        curl --silent "https://api.github.com/repos/docker/compose/releases/latest" |
        grep -Po '"tag_name": "\K.*?(?=")'
    }

    if ! [ -x "$(command -v docker-compose)" ]; then
        echo -e "$C  -Docker-Compose:$R$G Installing...$R"
        sudo curl -L https://github.com/docker/compose/releases/download/$(compose_release)/docker-compose-$(uname -s)-$(uname -m) \
        -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose

        echo -e "$RL$C  -Docker-Compose:$R$G Installed     $R"
    else 
        echo -e "$C  -Docker-Compose:$R$G Installed     $R"
    fi
}

# Check: Permissions
checkPerms() {
    echo -e "$C  -Permissions:$R$Y Setting...$R"
    
    if [ -f 9c-swarm-miner.sh ]; then chmod +xrw 9c-swarm-miner.sh; fi
    if [ -f docker-compose.yml ]; then chmod +rw docker-compose.yml; fi
    if [ -f settings.conf ]; then chmod +rw settings.conf; fi

    if [ -f build-config.sh ]; then chmod +x build-config.sh; fi
    if [ -f build-compose.sh ]; then chmod +xrw build-compose.sh; fi
    if [ -f manage-snapshot.sh ]; then chmod +x manage-snapshot.sh; fi
    if [ -f bin/setup.sh ]; then chmod +x bin/setup.sh; fi
    if [ -f bin//usr/local/bin/docker-compose ]; then sudo chmod +x /usr/local/bin/docker-compose; fi

    echo -e "$RL$C  -Permissions:$R$G Set       $R"
}

###############################
setupMain() {
    echo -e "$M>Initiating Setup for $(checkPlatform)$R"
    installCurl
    installUnzip
    installDocker
    installCompose
    checkPerms
    
    if [[ "$RESTART" == 1 ]]; then
        echo -e "$Re>Please log out and log in to complete the setup for Docker! Then re-run this script"$R
        echo
    fi

}
###############################
if [ "$1" == "--perms" ]; then
    checkPerms
    exit 0
else
    setupMain
    exit 0
fi