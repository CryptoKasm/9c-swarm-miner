#!/bin/bash
source bin/cklib.sh

# Check: ROOT
checkRoot

# pre-variables
PRK="$2"

# Change Private Key
changePrivateKey() {
    sLL
    sTitle "Private Key update"
    sSpacer
    OLDKEY=$(grep 'NC_PRIVATE_KEY=' settings.conf | sed 's/^.*=//')
    read -r -p "$(echo -e "$S""> You're current key: ""$OLDKEY"" would you like to update this? (Y/n)?: ""$RS")" PrivateUpdate
    if [[ $PrivateUpdate == [yY] || $PrivateUpdate == [yY][eE][sS] ]]; then
        read -r -p "$(echo -e "$P""|$sB SECRET_KEY: ""$RS")" NewPrK
        sSpacer
        read -r -p "$(echo -e "$S""> You're new key: ""$NewPrK"" is this correct?: ""$RS")" NewPrvKey
        if [[ $NewPrvKey == [yY] || $NewPrvKey == [yY][eE][sS] ]]; then
            $(sed -i 's/^NC_PRIVATE_KEY=.*$/NC_PRIVATE_KEY='"$NewPrK"'/' settings.conf)
            $(sed -i 's/\"--private-key=.*$/\"--private-key='"$NewPrK"'\",''/' docker-compose.yml)
            sL
            echo -e "$P""|$sB   Key has now been updated to ""$NewPrK""""$RS"
            sL
            sSpacer
            sL
            echo -e "$F""|$sB   Now run \"./9c-swarm-miner.sh\" for the new key to take affect""$RS"
            sL
            exit 0
        else
            exit 0
        fi
    else
        exit 0
    fi
}

# Change Public Key
changePrublicKey() {
    sLL
    sTitle "Public Key update"
    sSpacer
    OLDKEY=$(grep 'NC_PUBLIC_KEY=' settings.conf | sed 's/^.*=//')
    read -r -p "$(echo -e "$S""> You're current key: ""$OLDKEY"" would you like to update this? (Y/n)?: ""$RS")" PublicUpdate
    if [[ $PublicUpdate == [yY] || $PublicUpdate == [yY][eE][sS] ]]; then
        read -r -p "$(echo -e "$P""|$sB PUBLIC_KEY: ""$RS")" NewPbK
        sSpacer
        read -r -p "$(echo -e "$S""> You're new key: ""$NewPbK"" is this correct?: ""$RS")" NewPblKey
        if [[ $NewPblKey == [yY] || $NewPblKey == [yY][eE][sS] ]]; then
            $(sed -i 's/^NC_PUBLIC_KEY=.*$/NC_PUBLIC_KEY='"$NewPbK"'/' settings.conf)
            sL
            echo -e "$P""|$sB   Key has now been updated to ""$NewPbK""""$RS"
            sL
            exit 0
        else
            exit 0
        fi
    else
        exit 0
    fi
}

#!/bin/bash
source bin/cklib.sh

# Check: ROOT
checkRoot

# pre-variables
PRK="$2"

# Change Private Key
changePrivateKey() {
    sLL
    sTitle "Private Key update"
    sSpacer
    OLDKEY=$(grep 'NC_PRIVATE_KEY=' settings.conf | sed 's/^.*=//')
    read -r -p "$(echo -e "$S""> You're current key: ""$OLDKEY"" would you like to update this? (Y/n)?: ""$RS")" PrivateUpdate
    if [[ $PrivateUpdate == [yY] || $PrivateUpdate == [yY][eE][sS] ]]; then
        read -r -p "$(echo -e "$P""|$sB SECRET_KEY: ""$RS")" NewPrK
        sSpacer
        read -r -p "$(echo -e "$S""> You're new key: ""$NewPrK"" is this correct?: ""$RS")" NewPrvKey
        if [[ $NewPrvKey == [yY] || $NewPrvKey == [yY][eE][sS] ]]; then
            $(sed -i 's/^NC_PRIVATE_KEY=.*$/NC_PRIVATE_KEY='"$NewPrK"'/' settings.conf)
            $(sed -i 's/\"--private-key=.*$/\"--private-key='"$NewPrK"'\",''/' docker-compose.yml)
            sL
            echo -e "$P""|$sB   Key has now been updated to ""$NewPrK""""$RS"
            sL
            sSpacer
            sL
            echo -e "$F""|$sB   Now run \"./9c-swarm-miner.sh\" for the new key to take affect""$RS"
            sL
            exit 0
        else
            exit 0
        fi
    else
        exit 0
    fi
}

# Change Public Key
changePublicKey() {
    sLL
    sTitle "Public Key update"
    sSpacer
    OLDKEY=$(grep 'NC_PUBLIC_KEY=' settings.conf | sed 's/^.*=//')
    read -r -p "$(echo -e "$S""> You're current key: ""$OLDKEY"" would you like to update this? (Y/n)?: ""$RS")" PublicUpdate
    if [[ $PublicUpdate == [yY] || $PublicUpdate == [yY][eE][sS] ]]; then
        read -r -p "$(echo -e "$P""|$sB PUBLIC_KEY: ""$RS")" NewPbK
        sSpacer
        read -r -p "$(echo -e "$S""> You're new key: ""$NewPbK"" is this correct?: ""$RS")" NewPblKey
        if [[ $NewPblKey == [yY] || $NewPblKey == [yY][eE][sS] ]]; then
            $(sed -i 's/^NC_PUBLIC_KEY=.*$/NC_PUBLIC_KEY='"$NewPbK"'/' settings.conf)
            sL
            echo -e "$P""|$sB   Key has now been updated to ""$NewPbK""""$RS"
            exit 0
        else
            exit 0
        fi
    else
        exit 0
    fi
}

changeBothKeys() {
    sLL
    sTitle "Private & Public Key update"
    sSpacer
    OLDPRKEY=$(grep 'NC_PRIVATE_KEY=' settings.conf | sed 's/^.*=//')
    OLDPBKEY=$(grep 'NC_PUBLIC_KEY=' settings.conf | sed 's/^.*=//')
    read -r -p "$(echo -e "$S""> You're current private key: ""$OLDPRKEY"" & current public key: ""$OLDPBKEY"" would you like to update these? (Y/n)?: ""$RS")" PublicUpdate
    if [[ $PublicUpdate == [yY] || $PublicUpdate == [yY][eE][sS] ]]; then
        read -r -p "$(echo -e "$P""|$sB PRIVATE_KEY: ""$RS")" NewPrK
        sSpacer
        read -r -p "$(echo -e "$P""|$sB PUBLIC_KEY: ""$RS")" NewPbK
        sSpacer
        read -r -p "$(echo -e "$S""> You're new private key: ""$NewPrK"" & new public key: ""$NewPbK"" are these correct?: ""$RS")" NewPblKey
        if [[ $NewPblKey == [yY] || $NewPblKey == [yY][eE][sS] ]]; then
            $(sed -i 's/^NC_PUBLIC_KEY=.*$/NC_PUBLIC_KEY='"$NewPbK"'/' settings.conf)
            $(sed -i 's/^NC_PRIVATE_KEY=.*$/NC_PRIVATE_KEY='"$NewPrK"'/' settings.conf)
            $(sed -i 's/\"--private-key=.*$/\"--private-key='"$NewPrK"'\",''/' docker-compose.yml)
            sL
            echo -e "$P""|$sB   Keys have now been updated to private: ""$NewPrK"" public: ""$NewPbK""""$RS"
            sL
            sSpacer
            sL
            echo -e "$F""|$sB   Now run \"./9c-swarm-miner.sh\" for the new key to take affect""$RS"
            sL
            exit 0
        else
            exit 0
        fi
    else
        exit 0
    fi
}

###############################
case $1 in
--private)
    changePrivateKey
    exit 0
    ;;

--public)
    changePublicKey
    exit 0
    ;;

  --all)
    changeBothKeys
    exit 0
    ;;

*)
    exit 0
    ;;

esac
