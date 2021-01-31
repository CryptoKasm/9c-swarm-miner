#!/bin/bash


--------------------------------------------
>Nine Chronicles - Swarm Miner by CryptoKasm
>Version: 1.4.1-alpha
--------------------------------------------
>Initiating Setup for (WSL or Native)
   -Docker: Installed/Installing...
   -Compose: Installed/Installing...
   -Curl: Installed/Installing...
   -Unzip: Installed/Installing...
   -Permissions: Done
      --9c-swarm-miner.sh: Check/Not Found
      --docker: Check/Not Found
         ---Check docker group & add user to group
      --setup.sh: Check/Not Found
      --build-config.sh: Check/Not Found
      --build-compose.sh: Check/Not Found
      --manage-snapshot.sh: Check/Not Found
      --settings.conf: Check/Not Found
      --docker-compose.yml: Check/Not Found
>Building Configuration File
   -Please enter the requested information or press enter and edit later!
   -Edit configuration file after creation: settings.conf

   >SECRET_KEY:  

   -Creating file: settings.conf
>Building docker-compose.yml

   -Edit configuration file after creation: settings.conf

   >SECRET_KEY:  

   -Creating file: settings.conf

==========build-docker.sh
>Building Docker-Compose File
   -Build Parameters: Downloading...
   -Creating docker-compose.yml...
   -Temp files...
   >SECRET_KEY:  

   -Creating file: settings.conf
==========

==========manage-snapshot.sh
>Refreshing Snapshot
   -Docker Environment: Cleaning / Done
   -Snapshot: Checking... / Found / Not Found 
   -Snapshot: Cleaning... / Done
   -Snapshot: Downloading... / Done
   -Snapshot: Unzipping... / Done

>Preparing Volumes on Platform
   -Copying files to: swarm-miner$i-volume... / Done
==========

==========runDocker
>Starting Docker
   -Docker Environment: Cleaning / Done
   -Snapshot: Checking... / Found / Not Found 
   -Snapshot: Cleaning... / Done
   -Snapshot: Downloading... / Done
   -Snapshot: Unzipping... / Done

>Preparing Volumes on Platform
   -Copying files to: swarm-miner$i-volume... / Done
==========
=========================================================


echo -e "$S>Please log out and log in to complete the setup for Docker! Then re-run this script"$R
echo
echo -e "$S>Building Configuration File$R"
echo -e "$C   -Please enter the requested information or press enter and edit later!$R"
echo -e "$C   -Edit configuration file after creation:$R$G settings.conf$R"
echo
echo -e "$P   >SECRET_KEY:$R"  
echo
echo -e "$C   -Creating file:$R$G settings.conf$R"
echo
echo -e "$S>Building Configuration File$R"
echo -e "$C   -Build Parameters:$R$G$P Current / Downloading...$R"
echo -e "$C   -Creating file:$R$G docker-compose.yml$R"
echo -e "$C   -Cleaning temp files:$R$G$P Done / Processing...$R"
echo -e "$Re  -Run setup.sh before running this script!$R"
echo
echo -e "$S>Refreshing Snapshot$R"
echo -e "$C   -Docker Environment:$R$G$P Cleaning / Done$R"
echo -e "$C   -Snapshot:$R$G$P Checking... / Found / Not Found $R"
echo -e "$C   -Snapshot:$R$G$P Cleaning... / Done$R"
echo -e "$C   -Snapshot:$R$G$P Downloading... / Done$R"
echo -e "$C   -Snapshot:$R$G$P Unzipping... / Done$R"
echo
echo -e "$S>Preparing Volumes on Platform$R"
echo -e "$C   -Copying files to:$R$G$P swarm-miner$i-volume... / Done$R"


echo -e "$P-----------------------------------------------$R"
echo -e "$P-Windows Monitor (Full Log): $R"
echo -e "$G    Goto Docker and you can access logging for each individual container $R"
echo -e "$P-Windows Monitor (Mined Blocks Only): $R"
echo -e "$G    Search for Mined a block $R"
echo -e "$P-Linux Monitor (Full Log): $R"
echo -e "$G    docker-compose logs --tail=100 -f $R"
echo -e "$P-Linux Monitor (Mined Blocks Only): $R"
echo -e "$G    docker-compose logs --tail=100 -f | grep -A 10 --color -i 'Mined a block' $R"
echo -e "$P-Linux Monitor (Mined/Reorg/Append failed events): $R"
echo -e "$G    docker-compose logs --tail=1 -f | grep --color -i -E 'Mined a|reorged|Append failed' $R"
echo -e "$P-----------------------------------------------$R"