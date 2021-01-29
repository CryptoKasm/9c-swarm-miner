#!/bin/bash
source bin/consoleStyle.sh

# Update: Build Parameters from Online
updateBuildParams() {
    consoleEntry "2" "3" "2" "1"
    CURRENT="buildparams.txt"
    NEW="new.buildparams.txt"
    BUILDPARAMS="https://raw.githubusercontent.com/CryptoKasm/9c-swarm-miner/master/buildparams.txt"
    
    curl $BUILDPARAMS -s -o $NEW
    
    if [ -f $CURRENT ]; then
        consoleEntry "2" "3" "4" "1"
        #Check: Update
        if cmp -s $CURRENT $NEW; then
            return
        else
            rm -f $CURRENT
            cp $NEW $CURRENT
            rm -f docker-compose.yml
        fi
    else
        consoleEntry "2" "3" "4" "1"
        cp $NEW $CURRENT
    fi
}

# Build: Compose File
buildComposeFile() {
    COMPOSEFILE=docker-compose.yml

    cat <<EOF >$COMPOSEFILE
version: "2.4"

services:
EOF

    mainPORT=31234
    mainGqlPort=23061
    for ((i=1; i<=$NC_MINERS; i++)); do
        PORT=$((mainPORT++))
        GQL_PORT=$((mainGqlPort++))
        cat <<EOF >>$COMPOSEFILE
  swarm-miner$i:
    image: $DOCKERIMAGE
    mem_limit: $NC_RAM_LIMIT
    mem_reservation: $NC_RAM_RESERVE
    ports:
      - "$PORT:31234"
      - "$GQL_PORT:23061"
    volumes:
      - swarm-miner$i-volume:/app/data
      - ./keystore:/app/planetarium/keystore
    command: ['-V=$APV',
      '-G=https://9c-test.s3.ap-northeast-2.amazonaws.com/genesis-block-9c-main',
      '-D=5000000',
      '--store-type=rocksdb',
      '--store-path=/app/data',
      '--peer=027bd36895d68681290e570692ad3736750ceaab37be402442ffb203967f98f7b6,9c-main-seed-1.planetarium.dev,31234',
      '--peer=02f164e3139e53eef2c17e52d99d343b8cbdb09eeed88af46c352b1c8be6329d71,9c-main-seed-2.planetarium.dev,31234',
      '--peer=0247e289aa332260b99dfd50e578f779df9e6702d67e50848bb68f3e0737d9b9a5,9c-main-seed-3.planetarium.dev,31234',
      '--trusted-app-protocol-version-signer=03eeedcd574708681afb3f02fb2aef7c643583089267d17af35e978ecaf2a1184e',
      '--workers=50',
      '--confirmations=0',
      '--libplanet-node',
      '--ice-server=turn://0ed3e48007413e7c2e638f13ddd75ad272c6c507e081bd76a75e4b7adc86c9af:0apejou+ycZFfwtREeXFKdfLj2gCclKzz5ZJ49Cmy6I=@turn-us.planetarium.dev:3478',
      '--ice-server=turn://0ed3e48007413e7c2e638f13ddd75ad272c6c507e081bd76a75e4b7adc86c9af:0apejou+ycZFfwtREeXFKdfLj2gCclKzz5ZJ49Cmy6I=@turn-us2.planetarium.dev:3478',
      '--ice-server=turn://0ed3e48007413e7c2e638f13ddd75ad272c6c507e081bd76a75e4b7adc86c9af:0apejou+ycZFfwtREeXFKdfLj2gCclKzz5ZJ49Cmy6I=@turn-us3.planetarium.dev:3478',
      '--ice-server=turn://0ed3e48007413e7c2e638f13ddd75ad272c6c507e081bd76a75e4b7adc86c9af:0apejou+ycZFfwtREeXFKdfLj2gCclKzz5ZJ49Cmy6I=@turn-us4.planetarium.dev:3478',
      '--ice-server=turn://0ed3e48007413e7c2e638f13ddd75ad272c6c507e081bd76a75e4b7adc86c9af:0apejou+ycZFfwtREeXFKdfLj2gCclKzz5ZJ49Cmy6I=@turn-us5.planetarium.dev:3478',
      '--graphql-server',
      '--graphql-port=23061',
      "--private-key=$NC_PRIVATE_KEY",
      '--log-minimum-level=$LOG_LEVEL']
    restart: always
EOF
    done

    cat <<EOF >>$COMPOSEFILE
volumes:
EOF

    for ((i=1; i<=$NC_MINERS; i++)); do
        cat <<EOF >>$COMPOSEFILE
  swarm-miner$i-volume:
EOF
    done
}

# Clean: Temp Files
cleanTemp() {
    rm -f $NEW
}

###############################
composeMain() {
    consoleEntry "2" "3" "1" "1"
    if [ -f "settings.conf" ]; then
        source settings.conf
    else
        echo -e $P">$sB Please run setup! Then re-run this script"$RS
        exit 0
    fi
    
    updateBuildParams
    source buildparams.txt
    
    if [ -f "docker-compose.yml" ]; then
        consoleEntry "2" "3" "6" "1"
        rm -f docker-compose.yml 
        buildComposeFile
        consoleEntry "2" "3" "8" "1"
    else
        consoleEntry "2" "3" "6" "1"
        buildComposeFile
        consoleEntry "2" "3" "8" "1"
    fi
    consoleEntry "2" "10" "10" "0"
    #echo -ne $S"\e[0A\e[|$RS Docker-Compose $S|$C Ready          $S|$C $(prog "00")"$RS
    cleanTemp
    
    exit 0
}
###############################
composeMain