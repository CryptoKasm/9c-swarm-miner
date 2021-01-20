#!/bin/bash
if [ -f ".settings.conf" ]; then
    source .settings.conf 
else
    echo "No configuration file..."
fi

echo "--------------------------------------------"
echo "  Nine Chronicles - CryptoKasm Swarm Miner"
echo "  Version: 1.2.1-alpha"
echo "--------------------------------------------"

# Test: Root Privileges
if [ "$EUID" -ne 0 ]
  then echo "PLEASE RUN AS ROOT"
  exit
fi

# Check: Docker
checkDocker() {
    echo "> Checking for Docker"
    if ! [ -x "$(command -v docker)" ]; then
        echo "   --Installing..."
        #Removing leftovers if Docker is not found
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
    chmod +rw ./9c-swarm-miner.sh
    chmod +rw ./docker-compose.yml
    chmod +rw .settings.conf
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
        echo "   --Git: Installing..."
        sudo apt install -y curl
    else 
        echo "   --Git: Installed."
    fi
    if ! [ -x "$(command -v unzip)" ]; then
        echo "   --Git: Installing..."
        sudo apt install -y unzip
    else 
        echo "   --Git: Installed."
    fi
}

# Check: .settings.conf
checkConfig() {
    echo "> Checking for Configuration File"
    if [ -f ".settings.conf" ]; then
        echo "   --File Found: .settings.conf" 
    else
        echo "   --Creating Configuration File: .settings.conf"
        echo "    **EDIT THIS FILE TO CONFIGURE YOUR SWARM**"
        cat > .settings.conf << EOF
# Nine Chronicles - CryptoKasm Swarm Miner

DEBUG=0

# Nine Chronicles Private Key **KEEP SECRET**
NC_PRIVATE_KEY=

# Nine Chronicles Public Key **ALLOWS QUERY FOR NCG**
NC_PUBLIC_KEY=

# Amount of Miners **DOCKER CONTAINERS**
NC_MINERS=2

# Set MAX RAM Per Miner **PROTECTION FROM MEMORY LEAKS** 
NC_RAM_LIMIT=4096M

# Set MIN RAM Per Miner **SAVES RESOURCES FOR THAT CONTAINER** 
NC_RAM_RESERVE=2048M
EOF

    fi
}

# Build Compose File
buildComposeFile() {
COMPOSEFILE=docker-compose.yml
COMPOSESNIPPETURL="https://raw.githubusercontent.com/CryptoKasm/9c-swarm-miner/master/docker-compose.snippet"

cat <<EOF >$COMPOSEFILE
version: "2.4"

services:
EOF

curl $COMPOSESNIPPETURL -s -o docker-compose.snippet
source docker-compose.snippet
mainPORT=31234
for ((i = 1 ; i <= $NC_MINERS ; i++)); do
    PORT=$((mainPORT++))
    composeSnippet
done

cat <<EOF >>$COMPOSEFILE
volumes:
EOF

for ((i = 1 ; i <= $NC_MINERS ; i++)); do
cat <<EOF >>$COMPOSEFILE
  swarm-miner$i-volume:
EOF
done

echo "   --Cleaning temp file..."
rm docker-compose.snippet
}

# Check: Compose File
checkComposeFile() {
    echo "> Checking for docker-compose.yml"
    if [ -f "docker-compose.yml" ]; then
        echo "   --Found file." 
    else
        echo "   --Creating file..."
        buildComposeFile
    fi
}

# Refresh: Snapshot
checkSnapshot() {
    echo "> Refreshing Snapshot"
    echo "   --Cleaning docker environment..."

    docker-compose down -v      # Stops & deletes environment **snapshot**
    docker-compose --compatibility up -d        # Restarts to recreate clean environment
    docker-compose stop         # Stops cleaned environment for snapshot update
    
    echo "   --Checking for old snapshot..."
    NC_SNAPSHOT=latest-snapshot/9c-main-snapshot.zip
    if [ -f "$NC_SNAPSHOT" ]; then
        echo "      -Snapshot found."
        echo "      -Deleting..."
        rm -rf latest-snapshot/*
    else
        echo "      -Snapshot not found."
        mkdir -p latest-snapshot
    fi

    echo "   --Downloading new snapshot..."
    cd latest-snapshot
    curl -O https://download.nine-chronicles.com/latest/9c-main-snapshot.zip
    echo "      -Unzipping snapshot"
    unzip 9c-main-snapshot.zip
    echo "      -Removing tmp files"
    rm 9c-main-snapshot.zip
    
    echo " -> Preparing volumes..."
    # TODO: Add function to copy contents to proper volumes depending on if Linux/Windows
    echo "      -Check TODO :D"
}

# Run: Docker
runDocker() {
    echo ">Starting Docker..."
    echo ">>Please edit .settings.conf before running the dockers"
    echo ">>Start Miners by running: docker-compose up -d "
    # docker-compose up -d
    echo
    echo "   --Windows Monitor (Full Log): Goto Docker and you can access logging for each individual container."
    echo "   --Windows Monitor (Mined Blocks Only): Search for Mined a block."
    echo "   --Linux Monitor (Full Log): docker-compose logs --tail=100 -f"
    echo "   --Linux Monitor (Mined Blocks Only): docker-compose logs --tail=100 -f | grep -A 10 --color -i 'Mined a block"
}


#############################################
# Main
checkPrereqs
checkDocker
checkCompose
checkConfig
checkComposeFile
checkPerms
#checkSnapshot
runDocker
#############################################
# Debug
if [ "$DEBUG" == "1" ]; then
    echo
    echo "--------------------------------------------"
    echo "> Debug: Enabled"
    echo "  -$(docker --version)" 
    echo "  -Compose Verion: $(compose_release)"
    echo "  -$(git --version)"
    echo "--------------------------------------------"
fi
#############################################