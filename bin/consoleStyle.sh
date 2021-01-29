#!/bin/bash

# Style Codes
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

# Color Scheme
P=$Yellow
S=$Cyan
T=$Magenta
C=$Green
F=$Red

# Progress
prog() {
    case $1 in
    0)
        echo -ne ''
        ;;

    1)
        echo -ne $C'>>                     [10%]\r'$RS
        ;;

    2)
        echo -ne $C'>>>>                   [20%]\r'$RS
        ;;

    3)
        echo -ne $C'>>>>>>                 [30%]\r'$RS
        ;;

    4)
        echo -ne $C'>>>>>>>>               [40%]\r'$RS
        ;;

    5)
        echo -ne $C'>>>>>>>>>>             [50%]\r'$RS
        ;;

    6)
        echo -ne $C'>>>>>>>>>>>>           [60%]\r'$RS
        ;;

    7)
        echo -ne $C'>>>>>>>>>>>>>>         [70%]\r'$RS
        ;;


    8)
        echo -ne $C'>>>>>>>>>>>>>>>>       [80%]\r'$RS
        ;;


    9)
        echo -ne $C'>>>>>>>>>>>>>>>>>>     [90%]\r'$RS
        ;;


    10)
        echo -ne $C'>>>>>>>>>>>>>>>>>>>>   [100%]\r'$RS
        ;;


    *)
        echo -n $C'Unknown'$RS
        ;;
    esac
}

# Error with Code (check Docs for ErrorCodes )
errCode()
{
  echo -e $F">Error: $1"$RS 1>&2
  exit 1
}

consoleTitle() {
    TitleText=$1
    echo -e $S"> $TitleText"$RS

}

# Create Console Entry
consoleEntry() {
    case $1 in
    0)
        Process="               "
        ;;
    1)
        # Docker
        Process="Docker         "
        ;;

    2)
        # Docker-Compose
        Process="Docker-Compose "
        ;;

    3)
        # Curl
        Process="Curl           "
        ;;

    4)
        # Unzip
        Process="Unzip          "
        ;;

    5)
        # Permissions
        Process="Permissions    "
        ;;

    6)
        # Setting.conf
        Process="Settings       "
        ;;

    7)
        # docker-compose.yml
        Process="Docker-Compose "
        ;;

    8)
        Process="Environment    "
        ;;

    9)
        Process="Local Snapshot "
        ;;

    10)    
        Process="New Snapshot   "
        ;;

    11)
        Process="Miner$((i))_1    "
        ;;

    *)
        echo -n $S"No Label       "$RS
        ;;
    esac

    case $2 in

    1)
        # Installing...
        Status=$C"Installing... "$RS
        ;;

    2)
        # Installed
        Status=$C"Installed     "$RS
        ;;
    3)
        # Creating...
        Status=$C"Creating...    "$RS
        ;;
    4)
        # Found
        Status=$C"Found          "$RS
        ;;
    5)
        # Downloading...
        Status=$C"Downloading... "$RS
        ;;
    6)
        # Downloaded
        Status=$C"Downloaded     "$RS
        ;;
    7)
        # Windows Users: Run Docker Desktop
        Status=$C"Docker Desktop "$RS
        ;;
    8)
        # Setting...
        Status=$C"Setting...    "$RS
        ;;
    9)
        # Set
        Status=$C"Set           "$RS
        ;;
    10)
        # Created
        Status=$C"Created        "$RS
        ;;
    11)
        # Cleaning...
        Status=$C"Cleaning...    "$RS
        ;;
    12)
        # Clean Current        
        Status=$C"Clean          "$RS
        ;;
    13)
        # Current
        Status=$C"Current        "$RS
        ;;
    14)
        # Unzipping
        Status=$C"Unzipping...   "$RS
        ;;
    15)
        # Moving
        Status=$C"Moving...      "$RS
        ;;
    16)
        # Ready
        Status=$C"Ready          "$RS
        ;;
    17)
        # Ready
        Status=$C"Copying...     "$RS
        ;;
    *)
        # Error
        Status=$F"Error (x00)    "$RS
        ;;
    esac

    Progress="$(prog "$3")"

    UpdateConsole=$4

    if [ "$4" == 0 ]; then
        echo -e $S"| $RS$Process$S| $Status$S| $Progress"
    elif [ "$4" == 1 ]; then
        echo -ne $S"| $RS$Process$S| $Status$S| $Progress\r"
    else
        echo -ne $S"| $RS$Process$S| $Status$S| $Progress\e[$4A\e["
    fi
}

# Introduction
consoleIntro() {
    echo -e $P"-----------------------------------------------"$RS
    echo -e $P">$sB Nine Chronicles - Swarm Miner by CryptoKasm"$RS
    echo -e $P">$sB Version:$RS$S 1.4.1-alpha"$RS
    echo -e $P">$sB Platform:$RS$S $(checkPlatform)"$RS
    echo -e $P"-----------------------------------------------"$RS
}

# Test: Colors
testColors() {
    echo -e $P">$sB Color Selection"$RS
    echo
    echo -e $Yellow"  Yellow"$RS
    echo -e $Cyan"  Cyan"$RS
    echo -e $Magenta"  Magenta"$RS
    echo -e $Green"  Green"$RS
    echo -e $Red"  Red"$RS
}

# Test: Color Scheme
testColorScheme() {
    echo
    echo -e $P">$sB Selected Color Scheme"$RS
    echo
    echo -e $P"  Primary"$RS
    echo -e $S"  Secondary"$RS
    echo -e $T"  Text"$RS
    echo -e $C"  Complete"$RS
    echo -e $F"  Error"$RS
}

# Test: Progress
testProgress() {
    echo
    echo -e $P">$sB Progress Bar"$RS
    prog "1"
    echo
    prog "2"
    echo
    prog "3"
    echo
    prog "4"
    echo
    prog "5"
    echo
    prog "6"
    echo
    prog "7"
    echo
    prog "8"
    echo
    prog "9"
    echo
    prog "10"
    echo
}

# Test: Error with Codes
testErrorCodes() {
echo
echo -e $P">$sB Errors with Codes"$RS
#error "Can't find Docker"
echo -e $P"  Disabled until testing this function"$RS
echo
}

# Test: Console Output
testConsoleOutput() {
    echo -e $P"-----------------------------------------------"$RS
    echo -e $P">$sB Nine Chronicles - Swarm Miner by CryptoKasm"$RS
    echo -e $P">$sB Version:$RS$S 1.4.1-alpha"$RS
    echo -e $P">$sB Platform:$RS$S "$RS #$(checkPlatform)
    echo -e $P"-----------------------------------------------"$RS
    echo -e $S"> Initiating Setup for (WSL or Native)"$RS
    consoleEntry "1" "1" "1" "0"
    sleep 1
    consoleEntry "1" "1" "2" "0"
    sleep 1
    consoleEntry "1" "1" "3" "0"
    sleep 1
    consoleEntry "1" "1" "4" "0"
    sleep 1
    consoleEntry "1" "1" "5" "4"
    sleep 1
    consoleEntry "1" "1" "6" "1"
    sleep 1
    consoleEntry "1" "1" "7" "1"
    sleep 1
    consoleEntry "1" "1" "8" "1"
    sleep 1
    consoleEntry "1" "1" "9" "1"
    sleep 1
    consoleEntry "1" "1" "10" "1"
    sleep 1
    consoleEntry "1" "2" "0" "0"
    echo
    echo -e $P">$sB Please log out and log in to complete the setup for Docker! Then re-run this script"$RS
    clear
}

#intro
#testConsoleOutput

#> Initiating Setup for (WSL or Native)
#  | Settings       | Created        | >>>>>>>>>>             [50%]
#  | Settings       | Found          | >>>>>>>>>>             [50%]
#  | Docker-Compose | Copying...     | >>>>>>>>>>             [50%]
#  | Compose        | Current        | >>>>>>>>>>             [50%]
#  | Environment    | Moving...      | >>>>>>>>>>             [50%]
#  | Local Snapshot | Ready          | >>>>>>>>>>             [50%]
#  | New Snapshot   | Clean          | Unknown