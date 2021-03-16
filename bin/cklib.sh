#!/bin/bash

Debug=0
Version="1.6.2-beta"
Project="9c-swarm-miner"

#+---------------------------------------------+#
#| CryptoKasm Bash Library
#+---------------------------------------------+#
#| Color Styles
Yellow="\e[33m"
Cyan="\e[36m"
Magenta="\e[35m"
Green="\e[92m"
Red="\e[31m"
RS="\e[0m"
RSL="\e[1A\e["
RSL2="\e[2A\e["
RSL3="\e[3A\e["
sB="\e[1m"

#+-------------------------
# Color Scheme
P=$sB$Yellow
S=$sB$Cyan
T=$sB$Magenta
C=$sB$Green
F=$sB$Red

#+-------------------------
# Spinner
function _spinner() {
    # $1 start/stop
    #
    # on start: $2 display message
    # on stop : $2 process exit status
    #           $3 spinner function pid (supplied from stop_spinner)

    local on_success="DONE"
    local on_fail="FAIL"

    case $1 in
        start)
            # calculate the column where spinner and status msg will be displayed
            let column=$(tput cols)-${#2}-60
            # display message and position the cursor in $column column
            #echo -ne $P"|$T --$1    "$RS
            echo -ne $P"|$T --${2}    "$RS
            printf "%${column}s"

            # start spinner
            i=1
            sp='\|/-'
            delay=${SPINNER_DELAY:-0.15}

            while :
            do
                printf "$P\b${sp:i++%${#sp}:1}"
                sleep $delay
            done
            ;;
        stop)
            if [[ -z ${3} ]]; then
                echo "spinner is not running.."
                exit 1
            fi

            kill $3 > /dev/null 2>&1

            # inform the user uppon success or failure
            echo -en $P"\b["$RS
            if [[ $2 -eq 0 ]]; then
                echo -en $C"${on_success}"$RS
            else
                echo -en $F"${on_fail}"$RS
            fi
            echo -e $P"]"$RS
            ;;
        *)
            echo "invalid argument, try {start/stop}"
            exit 1
            ;;
    esac
}

function startSpinner {
    # $1 : msg to display
    _spinner "start" "${1}" &
    # set global spinner pid
    _sp_pid=$!
    disown
}

function stopSpinner {
    sleep 0.5
    # $1 : command exit status
    _spinner "stop" $1 $_sp_pid
    unset _sp_pid
}

#+-------------------------
# Console Text Styles
sIntro() {
    echo -e $P"+-----------------------------------------------------------------------------+"
    echo -e $P"|$S _________                        __          ____  __.                       "
    echo -e $P"|$S \_   ___ \_______ ___.__._______/  |_  ____ |    |/ _|____    ______ _____   "
    echo -e $P"|$S /    \  \/\_  __ <   |  |\____ \   __\/  _ \|      < \__  \  /  ___//     \  "
    echo -e $P"|$S \     \____|  | \/\___  ||  |_> >  | (  <_> )    |  \ / __ \_\___ \|  Y Y  \ "
    echo -e $P"|$S  \______  /|__|   / ____||   __/|__|  \____/|____|__ (____  /____  >__|_|  / "
    echo -e $P"|$S         \/        \/     |__|                       \/    \/     \/      \/  "
    echo -e $P"+-----------------------------------------------------------------------------+"
    echo -e $P"|$S Project: $Project   $P|$S Version: $Version   $P|$S Platform: $(checkPlatform)"
    echo -e $P"+-----------------------------------------------------------------------------+"$RS
}
sTitle() {
    echo -e $P">$S $1"$RS
}
sEntry() {
    echo -e $P"|$T --$1    "$RS
}
#sText() {}
sSpacer() {
    echo -e $P"|"$RS
}
sL() {
    echo -e $P"+-----------------------------------------+"$RS
}
sLL() {
    echo -e $P"+-----------------------------------------------------------------------------+"$RS
}
#sExample () {}
#sErorr() {}

sAction() {
    echo -e $P"|$sB   $1"$RS
}
sMenuEntry() {
    echo -e $P"|$S   $1$P.$S $2"$RS
}
sGraphQL() {
    echo -e $P"|$T   $1"$RS
}
#+---------------------------------------------+#
# Functions
#+---------------------------------------------+#
# Check: Debugging
function debug() {
    if [ "$Debug" == 1 ]; then echo "$1"; fi
}

# Exit: Error with Code (check Docs for ErrorCodes )
function errCode()
{
    echo -e $F">Error: $1"$RS 1>&2
    stopSpinner $?
    exit 1
}

# Check: ROOT
function checkRoot() { 
    debug "Check: ROOT"
    if [ "$EUID" -ne 0 ]; then
        sudo echo -ne "\r"
    fi
    debug "Check: ROOT > $EUID"
}

# Check: Platform
function checkPlatform() {
    debug "Check: Platform"
    if grep -q icrosoft /proc/version; then
        PLATFORM="WSL"
    else
        PLATFORM="NATIVE"
    fi
    debug "Check: Platform > $PLATFORM"
    echo $PLATFORM
}

# Check: Settings
function checkSettings() {
    if [ -f "settings.conf" ]; then
        source settings.conf
    else
        sAction "Please run setup! Then re-run this script"
        exit 1
    fi
}

# Check: Build Params
function checkBuildParams() {
    BUILDPARAMS="https://download.nine-chronicles.com/apv.json"
    APV=`curl --silent $BUILDPARAMS | jq -r '.apv'`
    DOCKERIMAGE=`curl --silent $BUILDPARAMS | jq -r '.docker'`
    SNAPSHOT0=`curl --silent $BUILDPARAMS | jq -r '."snapshotPaths:"[0]'`
    SNAPSHOT1=`curl --silent $BUILDPARAMS | jq -r '."snapshotPaths:"[1]'`
    CurlSnap1=`curl -s -w '%{time_connect}' -o /dev/null $SNAPSHOT0`
    CurlSnap2=`curl -s -w '%{time_connect}' -o /dev/null $SNAPSHOT1`

    if [[ $CurlSnap1 > $CurlSnap2 ]]; then
        if [[ `wget -S --spider $SNAPSHOT1.zip  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then
            SNAPSHOT=`echo $SNAPSHOT1.zip`
        else
            SNAPSHOT=`echo $SNAPSHOT0.zip`
        fi
    else
        if [[ `wget -S --spider $SNAPSHOT1.zip  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then
            SNAPSHOT=`echo $SNAPSHOT0.zip`
        else
            SNAPSHOT=`echo $SNAPSHOT1.zip`
        fi
    fi

}

function optionDonate() {
    sLL
    sTitle "Feel like making a small donation?"
    sEntry "CryptoKasm Public ID:$C 0xc17fC5cC7df1757D656B2431B3621b42E556B523$RS"
    #echo -e $P">$C You can do so by running the command: ./9c-swarm-miner.sh --donate"$RS
}

function displayDonate() {
    sLL
    sTitle "Donate to CryptoKasm"
    sEntry "For security purposes we require you to copy and paste our address as a way for confirmation"
    sEntry "CryptoKasm Public ID:$C 0xc17fC5cC7df1757D656B2431B3621b42E556B523$RS"
    sSpacer
    read -p "$(echo -e $P"|$S CryptoKasm Public ID: "$RS)" playerPublicID
    read -p "$(echo -e $P"|$S Amount of NCG to donate: "$RS)" amountNCG
    sSpacer
    read -p "$(echo -e $P"|$S Are you sure you want to send $C$amountNCG$S NCG to Player ID: $C$playerPublicID$S? (Y/n) "$RS)" confirmDonate
    sSpacer
    if [[ $confirmDonate == [yY] || $confirmDonate == [yY][eE][sS] ]]; then
        sAction "Sent successfully!"
        sAction "Transaction ID:$C 17bb2f568f41bd7964a1e79ceeab6f5132df66f4e652f6f5601a80d42ee4f6a8"
        sSpacer
        sAction "Thank you for your donation! We really appreciate it!"
        sAction "Need help or support? Dont hesitate to contact us!"
    else
        exit 0
    fi
    sLL
}

###############################################
function ckMain() {
    #sIntro
    #sTitle "Setup"
    #sEntry "curl..."
    #checkRoot
    #checkPlatform
    #startSpinner "Testing: Spinner"
    #sleep 5
    #stopSpinner $?
    #optionDonate
    displayDonate
}
###############################################
#ckMain