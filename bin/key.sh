#!/bin/bash
source bin/cklib.sh

# Check: ROOT
checkRoot

# pre-variables
PRK="$2"

# Change Private Key
changePrivateKey() {
    sLL
    sTitle "Private Key Update"

    OLDKEY=$(grep 'NC_PRIVATE_KEY=' settings.conf | sed 's/^.*=//')
    sAction "Current Private Key: $OLDKEY"
    sSpacer

    read -r -p "$(echo -e "$P"">$S Would you like to update this? (Y/n): ""$RS")" PrivateUpdate
    if [[ $PrivateUpdate == [yY] || $PrivateUpdate == [yY][eE][sS] ]]; then
        read -r -p "$(echo -e "$P""|$sB   SECRET_KEY: ""$RS")" NewPrK
        sSpacer
        read -r -p "$(echo -e "$P"">$S Is this Private Key correct: $P""$NewPrK""$S? (Y/n): ""$RS")" NewPrvKey
        if [[ $NewPrvKey == [yY] || $NewPrvKey == [yY][eE][sS] ]]; then
            $(sed -i 's/^NC_PRIVATE_KEY=.*$/NC_PRIVATE_KEY='"$NewPrK"'/' settings.conf)
            $(sed -i 's/\"--miner-private-key=.*$/\"--miner-private-key='"$NewPrK"'\",''/' docker-compose.yml)
            sL
            echo -e "$P"">$C Private Key was successfully updated!""$RS"
            echo -e "$P""|$S   New Private Key: $P""$NewPrK""""$RS"
            sL
            echo -e "$P"">$S Changes will take effect on next start up!""$RS"
            exit 0
        else
            sSpacer
            sAction "Private Key was NOT saved!"
            exit 0
        fi
    else
        sSpacer
        sAction "No changes were made!"
        exit 0
    fi
}

# Change Public Key
changePublicKey() {
    sLL
    sTitle "Public Key Update"

    OLDKEY=$(grep 'NC_PUBLIC_KEY=' settings.conf | sed 's/^.*=//')
    sAction "Current Public Key: $OLDKEY"
    sSpacer

    read -r -p "$(echo -e "$P"">$S Would you like to update this? (Y/n): ""$RS")" PublicUpdate
    if [[ $PublicUpdate == [yY] || $PublicUpdate == [yY][eE][sS] ]]; then
        read -r -p "$(echo -e "$P""|$sB   PUBLIC_KEY: ""$RS")" NewPbK
        sSpacer
        read -r -p "$(echo -e "$P"">$S Is this Public Key correct: $P""$NewPbK""$S? (Y/n): ""$RS")" NewPblKey
        if [[ $NewPblKey == [yY] || $NewPblKey == [yY][eE][sS] ]]; then
            $(sed -i 's/^NC_PUBLIC_KEY=.*$/NC_PUBLIC_KEY='"$NewPbK"'/' settings.conf)
            sL
            echo -e "$P"">$C Public Key was successfully updated!""$RS"
            echo -e "$P""|$S   New Public Key: $P""$NewPbK""""$RS"
            sL
            echo -e "$P"">$S Changes will take effect on next start up!""$RS"
            exit 0
        else
            sSpacer
            sAction "Public Key was NOT saved!"
            exit 0
        fi
    else
        sSpacer
        sAction "No changes were made!"
        exit 0
    fi
}

changeBothKeys() {
    sLL
    sTitle "Private & Public Key Update"

    OLDPRKEY=$(grep 'NC_PRIVATE_KEY=' settings.conf | sed 's/^.*=//')
    OLDPBKEY=$(grep 'NC_PUBLIC_KEY=' settings.conf | sed 's/^.*=//')
    sAction "Current Private Key: $OLDPRKEY"
    sAction "Current Public Key: $OLDPBKEY"
    sSpacer

    read -r -p "$(echo -e "$P"">$S Would you like to update these? (Y/n): ""$RS")" PublicUpdate
    if [[ $PublicUpdate == [yY] || $PublicUpdate == [yY][eE][sS] ]]; then
        read -r -p "$(echo -e "$P""|$sB   PRIVATE_KEY: ""$RS")" NewPrK
        read -r -p "$(echo -e "$P""|$sB   PUBLIC_KEY: ""$RS")" NewPbK
        sSpacer
        read -r -p "$(echo -e "$P"">$S Is this Private Key correct: $P""$NewPrK""$S? (Y/n): ""$RS")" NewPrvKey
        if ! [[ $NewPrvKey == [yY] || $NewPrvKey == [yY][eE][sS] ]]; then
            sSpacer
            sAction "Keys were NOT saved!"
            exit 0
        fi

        sSpacer
        read -r -p "$(echo -e "$P"">$S Is this Public Key correct: $P""$NewPbK""$S? (Y/n): ""$RS")" NewPblKey
        if [[ $NewPblKey == [yY] || $NewPblKey == [yY][eE][sS] ]]; then
            $(sed -i 's/^NC_PUBLIC_KEY=.*$/NC_PUBLIC_KEY='"$NewPbK"'/' settings.conf)
            $(sed -i 's/^NC_PRIVATE_KEY=.*$/NC_PRIVATE_KEY='"$NewPrK"'/' settings.conf)
            $(sed -i 's/\"--miner-private-key=.*$/\"--miner-private-key='"$NewPrK"'\",''/' docker-compose.yml)
            sL
            echo -e "$P"">$C Private Key was successfully updated!""$RS"
            echo -e "$P""|$S   New Private Key: $P""$NewPrK""""$RS"
            sSpacer
            echo -e "$P"">$C Public Key was successfully updated!""$RS"
            echo -e "$P""|$S   New Public Key: $P""$NewPbK""""$RS"
            sL
            echo -e "$P"">$S Changes will take effect on next start up!""$RS"
            exit 0
        else
            sSpacer
            sAction "Keys were NOT saved!"
            exit 0
        fi
    else
        sSpacer
        sAction "No changes were made!"
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
