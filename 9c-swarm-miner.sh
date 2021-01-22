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

# Check: Platform
checkPlatform() {
    if grep -q icrosoft /proc/version; then
        echo "> Platform: Ubuntu on Windows (WSL)"
        PLATFORM="WSL"
        
    else
        echo "> Platform: Native Linux"
        PLATFORM="NATIVE"
    fi
}

# Check: Docker
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
    chmod +xrw ./9c-swarm-miner.sh
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

# Turn on/off debugging for this script (1/0)
DEBUG=0

# Set log level for all miners
LOG_LEVEL=debug

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
sleep 1
source docker-compose.snippet
mainPORT=31234
mainGqlPort=9331
for ((i=1; i<=$NC_MINERS; i++)); do
    PORT=$((mainPORT++))
    GQL_PORT=$((mainGqlPort++))
    composeSnippet
done

cat <<EOF >>$COMPOSEFILE
volumes:
EOF

for ((i=1; i<=$NC_MINERS; i++)); do
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
        echo "   --TODO:Creating file..."
        buildComposeFile
    fi
}

# Refresh: Snapshot
checkSnapshot() {
    echo "> Refreshing Snapshot"
    echo "   --Cleaning docker environment..."

    docker-compose down -v      # Stops & deletes environment **snapshot**
    docker-compose up -d        # Restarts to recreate clean environment
    docker-compose stop         # Stops cleaned environment for snapshot update
    
    echo "   --Checking for old snapshot..."
    NC_SNAPSHOT=latest-snapshot/9c-main
    if [ -d "$NC_SNAPSHOT" ]; then
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
    
    if [ $PLATFORM = "WSL" ]; then
        echo "Ubuntu on Windows"
        # Windows Explorer Location: \\wsl$\docker-desktop-data\version-pack-data\community\docker\volumes
        # Access on Linux Side: Following https://github.com/microsoft/WSL/discussions/4176
        # VOLUMES=/var/lib/docker/volumes/9c-swarm-miner_swarm-miner$((i))-volume/_data/
    else
        echo " Native Linux"
        VOLUMES=/var/lib/docker/volumes/9c-swarm-miner_swarm-miner$((i))-volume/_data/
    fi

    for ((i=1; i<=$NC_MINERS; i++)); do
        echo "   --Copying to swarm-miner$i-volume..."
        # NOTE: The location and the name of the docker volumes may differ, depending on the system.
        sudo cp -r ./* $VOLUMES
    done
    echo "   --Volumes have been updated with newest snapshot."
}

# Run: Docker
runDocker() {
    echo ">>Starting Docker..."
    echo "->Please edit .settings.conf before running the dockers"
    if [ -z "$NC_PRIVATE_KEY" ]; then
        echo
        echo ">>You must set your PRIVATE_KEY before autorun is enabled!" 
    else
        docker-compose up -d
    fi
    echo
    echo "-> Windows Monitor (Full Log): Goto Docker and you can access logging for each individual container."
    echo "-> Windows Monitor (Mined Blocks Only): Search for Mined a block."
    echo "-> Linux Monitor (Full Log): docker-compose logs --tail=100 -f"
    echo "-> Linux Monitor (Mined Blocks Only): docker-compose logs --tail=100 -f | grep -A 10 --color -i 'Mined a block"
    echo "-> Linux Monitor (Mined/Reorg/Append failed events): docker-compose logs --tail=1 -f | grep --color -i -E 'Mined a|reorged|Append failed'"
}


#############################################
# Main
checkPlatform
checkPrereqs
checkDocker
checkCompose
checkConfig
checkComposeFile
checkPerms
checkSnapshot
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